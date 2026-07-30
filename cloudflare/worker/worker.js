// YCT Upload Worker
// Deployed at: yct-upload.yct-app.workers.dev
// Handles: POST /upload (file → R2) and DELETE /delete (remove from R2)

export default {
  async fetch(request, env) {
    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': '*',
    };
    if (request.method === 'OPTIONS') return new Response(null, { headers: cors });

    const url = new URL(request.url);

    // POST /upload
    if (request.method === 'POST' && url.pathname === '/upload') {
      try {
        const fd   = await request.formData();
        const file = fd.get('file');
        const path = fd.get('path');
        if (!file || !path) return new Response(
          JSON.stringify({ error: 'Missing file or path' }),
          { status: 400, headers: { ...cors, 'Content-Type': 'application/json' }});
        const safe = path.replace(/\.\./g, '').replace(/^\/+/, '');
        await env.YCT_BUCKET.put(safe, file.stream(), {
          httpMetadata: { contentType: file.type || 'application/octet-stream' }
        });
        return new Response(
          JSON.stringify({ success: true,
            url: `https://pub-360b7b3324fb4f22bb35e656f476062a.r2.dev/${safe}`,
            path: safe }),
          { status: 200, headers: { ...cors, 'Content-Type': 'application/json' }});
      } catch(e) {
        return new Response(JSON.stringify({ error: e.message }),
          { status: 500, headers: { ...cors, 'Content-Type': 'application/json' }});
      }
    }

    // DELETE /delete
    if (request.method === 'DELETE' && url.pathname === '/delete') {
      try {
        const body = await request.json();
        if (!body.path) return new Response(
          JSON.stringify({ error: 'Missing path' }),
          { status: 400, headers: { ...cors, 'Content-Type': 'application/json' }});
        const safe = body.path.replace(/\.\./g, '').replace(/^\/+/, '');
        await env.YCT_BUCKET.delete(safe);
        return new Response(
          JSON.stringify({ success: true, deleted: safe }),
          { status: 200, headers: { ...cors, 'Content-Type': 'application/json' }});
      } catch(e) {
        return new Response(JSON.stringify({ error: e.message }),
          { status: 500, headers: { ...cors, 'Content-Type': 'application/json' }});
      }
    }

    return new Response('YCT Upload Worker — OK', { headers: cors });
  }
};
