using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class YouTubeVideo
    {
        public string VideoId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ThumbnailUrl { get; set; } = string.Empty;
        public string ChannelTitle { get; set; } = string.Empty;
        public DateTime PublishedAt { get; set; }
        public string Duration { get; set; } = string.Empty;
        public long ViewCount { get; set; }
        public string VideoUrl => $"https://www.youtube.com/watch?v={VideoId}";
        public string EmbedUrl => $"https://www.youtube.com/embed/{VideoId}";
        public bool IsLiveStream { get; set; }
        public string LiveStatus { get; set; } = string.Empty; // "live", "upcoming", "none"
    }

    public class YouTubeSearchRequest
    {
        public string Query { get; set; } = string.Empty;
        public int MaxResults { get; set; } = 10;
        public string Order { get; set; } = "relevance"; // relevance, date, rating, viewCount, title
        public string Type { get; set; } = "video"; // video, channel, playlist
        public bool LiveOnly { get; set; } = false;
    }

    public class YouTubeSearchResponse
    {
        public List<YouTubeVideo> Videos { get; set; } = new List<YouTubeVideo>();
        public string NextPageToken { get; set; } = string.Empty;
        public string PrevPageToken { get; set; } = string.Empty;
        public int TotalResults { get; set; }
    }
}
