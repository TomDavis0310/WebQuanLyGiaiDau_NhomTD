using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public interface IYouTubeService
    {
        /// <summary>
        /// Search for videos on YouTube
        /// </summary>
        Task<YouTubeSearchResponse> SearchVideosAsync(YouTubeSearchRequest request);

        /// <summary>
        /// Get video details by video ID
        /// </summary>
        Task<YouTubeVideo> GetVideoDetailsAsync(string videoId);

        /// <summary>
        /// Search for live streams
        /// </summary>
        Task<YouTubeSearchResponse> SearchLiveStreamsAsync(string query, int maxResults = 10);

        /// <summary>
        /// Search for highlights videos
        /// </summary>
        Task<YouTubeSearchResponse> SearchHighlightsAsync(string query, int maxResults = 10);

        /// <summary>
        /// Extract video ID from YouTube URL
        /// </summary>
        string ExtractVideoIdFromUrl(string youtubeUrl);

        /// <summary>
        /// Validate if URL is a valid YouTube URL
        /// </summary>
        bool IsValidYouTubeUrl(string url);

        /// <summary>
        /// Get recommended videos for a tournament/match
        /// </summary>
        Task<YouTubeSearchResponse> GetRecommendedVideosAsync(string tournamentName, string sportName, int maxResults = 5);
    }
}
