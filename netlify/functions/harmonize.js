// AI "put me in the scene" pass — regenerates the whole photo from the scene + the guest.
//   POST { images: [sceneDataURI, guestDataURI], prompt }  ->  { id }          (starts the job)
//   (or { image, prompt } for a single-image edit model)
//   GET  ?id=<id>  ->  { status: "starting"|"processing" }
//                   |  { status: "succeeded", image: "data:image/jpeg;base64,..." }
//                   |  { status: "failed", error }
// Two-step (start + poll) so no single function call runs past Netlify's time limit.
// Default model: Google Nano Banana (Gemini image) on Replicate — takes several reference images
// and keeps faces well. Override with HARMONIZE_MODEL (e.g. black-forest-labs/flux-kontext-pro for a
// single-image relight). Uses the same REPLICATE_API_TOKEN.

import Replicate from "replicate";

const replicate = new Replicate();
const MODEL = process.env.HARMONIZE_MODEL || "google/nano-banana";
const MULTI = !/flux-kontext/.test(MODEL);            // models that take an array of reference images

const json = (status, body) => ({
  statusCode: status,
  headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
  body: JSON.stringify(body),
});

function outputUrl(output) {
  let url = output;
  if (Array.isArray(url)) url = url[0];
  if (url && typeof url.url === "function") url = url.url();
  if (url && typeof url === "object" && url.href) url = url.href;
  return typeof url === "string" ? url : null;
}

export async function handler(event) {
  if (!process.env.REPLICATE_API_TOKEN) return json(500, { error: "REPLICATE_API_TOKEN not configured" });

  try {
    if (event.httpMethod === "POST") {
      let image, images, prompt;
      try { ({ image, images, prompt } = JSON.parse(event.body || "{}")); }
      catch { return json(400, { error: "bad JSON body" }); }
      images = images || (image ? [image] : []);
      if (!images.length || !prompt) return json(400, { error: "images and prompt required" });

      const input = MULTI
        ? { prompt, image_input: images, aspect_ratio: "match_input_image", output_format: "jpg" }
        : { prompt, input_image: images[0], aspect_ratio: "match_input_image", output_format: "jpg", safety_tolerance: 2 };
      const prediction = await replicate.predictions.create({ model: MODEL, input });
      return json(200, { id: prediction.id });
    }

    if (event.httpMethod === "GET") {
      const id = event.queryStringParameters && event.queryStringParameters.id;
      if (!id) return json(400, { error: "id required" });
      const p = await replicate.predictions.get(id);
      if (p.status === "failed" || p.status === "canceled")
        return json(200, { status: "failed", error: String(p.error || p.status).slice(0, 300) });
      if (p.status !== "succeeded") return json(200, { status: p.status });

      const url = outputUrl(p.output);
      if (!url) return json(502, { status: "failed", error: "unexpected output" });
      const res = await fetch(url);                       // hand back same-origin bytes (no canvas taint)
      if (!res.ok) return json(502, { status: "failed", error: "fetch result " + res.status });
      const buf = Buffer.from(await res.arrayBuffer());
      const mime = res.headers.get("content-type") || "image/jpeg";
      return json(200, { status: "succeeded", image: `data:${mime};base64,${buf.toString("base64")}` });
    }

    return json(405, { error: "POST or GET only" });
  } catch (e) {
    return json(502, { status: "failed", error: String(e).slice(0, 300) });
  }
}
