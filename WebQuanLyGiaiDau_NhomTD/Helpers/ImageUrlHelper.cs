using System;

namespace WebQuanLyGiaiDau_NhomTD.Helpers
{
    public static class ImageUrlHelper
    {
        /// <summary>
        /// Normalize image URL for use in src attributes.
        /// - ensures leading slash
        /// - converts backslashes to forward slashes
        /// - percent-encodes path segments (so spaces become %20)
        /// - returns a sensible fallback when null/empty
        /// </summary>
        public static string NormalizeImageUrl(string? url, string fallback = "/images/download.jpg")
        {
            if (string.IsNullOrWhiteSpace(url)) return fallback;

            // Trim and replace backslashes
            var u = url.Trim().Replace("\\", "/");

            // Ensure leading slash
            if (!u.StartsWith("/")) u = "/" + u;

            // Split into segments and escape each to preserve slashes
            try
            {
                var segments = u.Split('/');
                for (int i = 1; i < segments.Length; i++) // skip leading empty segment
                {
                    segments[i] = Uri.EscapeDataString(segments[i]);
                }
                return string.Join('/', segments);
            }
            catch
            {
                // Best-effort fallback
                return u.Replace(" ", "%20");
            }
        }
    }
}
