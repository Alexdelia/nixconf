{ config, lib, ... }:
{
  xdg = {
    mimeApps = {
      enable = true;

      defaultApplications =
        lib.genAttrs [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chrome"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
          "x-scheme-handler/mailto"

          "text/html"
          "application/pdf"

          "image/png"
          "image/jpeg"
          "image/gif"
          "image/svg+xml"
          "image/webp"
          "image/bmp"
          "image/apng"
          "image/avif"
          "image/jxl"
          "image/x-icon"
          "image/vnd.microsoft.icon"

          "audio/mpeg"
          "audio/ogg"
          "audio/flac"
          "audio/wav"
          "audio/aac"
          "audio/mp4"
          "audio/x-m4a"

          "video/mp4"
          "video/webm"
          "video/ogg"
          "video/quicktime"
        ] (_: config.dm.browser)
        // lib.genAttrs [
          "text/plain"
          "text/markdown"
          "text/csv"
          "text/xml"

          "application/json"
          "application/xml"
          "application/xhtml+xml"
          "application/rss+xml"
          "application/atom+xml"
          "application/rdf+xml"
        ] (_: config.dm.editor)
        // {
          "x-scheme-handler/slack" = "slack.desktop";
        };
    };
    configFile."mimeapps.list".force = true;
    dataFile."applications/mimeapps.list".force = true;
  };
}
