using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Services;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class YouTubeController : Controller
    {
        private readonly IYouTubeService _youtubeService;
        private readonly ApplicationDbContext _context;

        public YouTubeController(IYouTubeService youtubeService, ApplicationDbContext context)
        {
            _youtubeService = youtubeService;
            _context = context;
        }

        // GET: YouTube
        public IActionResult Index()
        {
            return View();
        }

        // GET: YouTube/Demo
        public IActionResult Demo()
        {
            return View();
        }

        // GET: YouTube/Search
        public async Task<IActionResult> Search(string query, int maxResults = 10, string type = "video")
        {
            if (string.IsNullOrEmpty(query))
            {
                return View(new YouTubeSearchResponse());
            }

            var request = new YouTubeSearchRequest
            {
                Query = query,
                MaxResults = maxResults,
                Type = type
            };

            var result = await _youtubeService.SearchVideosAsync(request);
            ViewBag.Query = query;
            return View(result);
        }

        // GET: YouTube/SearchHighlights
        public async Task<IActionResult> SearchHighlights(string query, int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return Json(new { success = false, message = "Query is required" });
            }

            var result = await _youtubeService.SearchHighlightsAsync(query, maxResults);
            return Json(new { success = true, data = result });
        }

        // GET: YouTube/SearchLiveStreams
        public async Task<IActionResult> SearchLiveStreams(string query, int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return Json(new { success = false, message = "Query is required" });
            }

            var result = await _youtubeService.SearchLiveStreamsAsync(query, maxResults);
            return Json(new { success = true, data = result });
        }

        // POST: YouTube/UpdateMatchVideo
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateMatchVideo(int matchId, string highlightsUrl, string liveStreamUrl, string description)
        {
            try
            {
                var match = await _context.Matches.FindAsync(matchId);
                if (match == null)
                {
                    return Json(new { success = false, message = "Match not found" });
                }

                // Validate YouTube URLs
                if (!string.IsNullOrEmpty(highlightsUrl) && !_youtubeService.IsValidYouTubeUrl(highlightsUrl))
                {
                    return Json(new { success = false, message = "Invalid highlights URL" });
                }

                if (!string.IsNullOrEmpty(liveStreamUrl) && !_youtubeService.IsValidYouTubeUrl(liveStreamUrl))
                {
                    return Json(new { success = false, message = "Invalid live stream URL" });
                }

                // match.HighlightsVideoUrl = highlightsUrl; // Tạm comment để fix migration
                // match.LiveStreamUrl = liveStreamUrl; // Tạm comment để fix migration
                // match.VideoDescription = description; // Tạm comment để fix migration

                await _context.SaveChangesAsync();

                return Json(new { success = true, message = "Video URLs updated successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        // GET: YouTube/GetVideoDetails
        public async Task<IActionResult> GetVideoDetails(string videoId)
        {
            if (string.IsNullOrEmpty(videoId))
            {
                return Json(new { success = false, message = "Video ID is required" });
            }

            var video = await _youtubeService.GetVideoDetailsAsync(videoId);
            if (video == null)
            {
                return Json(new { success = false, message = "Video not found" });
            }

            return Json(new { success = true, data = video });
        }

        // GET: YouTube/GetRecommendedVideos
        public async Task<IActionResult> GetRecommendedVideos(string tournamentName, string sportName, int maxResults = 5)
        {
            if (string.IsNullOrEmpty(tournamentName) || string.IsNullOrEmpty(sportName))
            {
                return Json(new { success = false, message = "Tournament name and sport name are required" });
            }

            var result = await _youtubeService.GetRecommendedVideosAsync(tournamentName, sportName, maxResults);
            return Json(new { success = true, data = result });
        }

        // GET: YouTube/ExtractVideoId
        public IActionResult ExtractVideoId(string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return Json(new { success = false, message = "URL is required" });
            }

            var videoId = _youtubeService.ExtractVideoIdFromUrl(url);
            if (string.IsNullOrEmpty(videoId))
            {
                return Json(new { success = false, message = "Invalid YouTube URL" });
            }

            return Json(new { success = true, videoId = videoId });
        }
    }
}
