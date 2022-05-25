/**
 * Rewrites origin (s3 bucket) requests to index.html for all client apps (home, chat, admin).
 * 
 * @param {*} event 
 * @returns 
 */
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (["PATCH", "PUT", "POST", "DELETE"].includes(request.method)) {
    return request;
  }

  if (uri == "" || uri == "/") {
    var response = {
      statusCode: 302,
      statusDescription: "Found",
      headers: { location: { value: "/home/" } },
    };

    return response;
  }

  if (uri == "/home" || uri == "/home/") {
    request.uri = "/home/index.html";
  }
  if (uri == "/chat" || uri == "/chat/") {
    request.uri = "/chat/index.html";
  }
  if (uri == "/admin" || uri == "/admin/") {
    request.uri = "/admin/index.html";
  }

  return request;
}
