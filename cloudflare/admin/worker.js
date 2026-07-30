// Serves the admin panel index.html
// Cloudflare Workers Sites — static asset serving
export default {
  async fetch(request, env) {
    return env.ASSETS.fetch(request);
  }
};
