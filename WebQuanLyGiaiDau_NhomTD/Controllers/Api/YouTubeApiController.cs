using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Services;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    /// <summary>
    /// API Controller for YouTube video integration
    /// Provides endpoints for searching videos, managing match videos, and recommendations
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    public class YouTubeApiController : ControllerBase
    {
        private readonly IYouTubeService _youtubeService;
        private readonly ApplicationDbContext _context;

        public YouTubeApiController(IYouTubeService youtubeService, ApplicationDbContext context)
        {
            _youtubeService = youtubeService;
            _context = context;
        }

        /// <summary>
        /// Search YouTube videos
        /// </summary>
        /// <param name="query">Search query</param>
        /// <param name="maxResults">Maximum number of results (default: 10)</param>
        /// <param name="type">Type of content: video, channel, playlist (default: video)</param>
        /// <returns>List of YouTube videos matching the query</returns>
        [HttpGet("search")]
        public async Task<ActionResult<object>> SearchVideos(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10,
            [FromQuery] string type = "video")
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { success = false, message = "Query is required" });
            }

            try
            {
                var request = new YouTubeSearchRequest
                {
                    Query = query,
                    MaxResults = maxResults,
                    Type = type
                };

                var result = await _youtubeService.SearchVideosAsync(request);
                return Ok(new 
                { 
                    success = true, 
                    data = result,
                    query = query,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API is not available. Please check your API key configuration.", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Search highlight videos with automatic filtering
        /// </summary>
        /// <param name="query">Search query</param>
        /// <param name="maxResults">Maximum number of results (default: 10)</param>
        /// <returns>List of highlight videos</returns>
        [HttpGet("highlights")]
        public async Task<ActionResult<object>> SearchHighlights(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { success = false, message = "Query is required" });
            }

            try
            {
                var result = await _youtubeService.SearchHighlightsAsync(query, maxResults);
                return Ok(new 
                { 
                    success = true, 
                    data = result,
                    query = query,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Search live stream videos
        /// </summary>
        /// <param name="query">Search query</param>
        /// <param name="maxResults">Maximum number of results (default: 10)</param>
        /// <returns>List of live stream videos</returns>
        [HttpGet("livestreams")]
        public async Task<ActionResult<object>> SearchLiveStreams(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { success = false, message = "Query is required" });
            }

            try
            {
                var result = await _youtubeService.SearchLiveStreamsAsync(query, maxResults);
                return Ok(new 
                { 
                    success = true, 
                    data = result,
                    query = query,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get video details by YouTube video ID
        /// </summary>
        /// <param name="videoId">YouTube video ID</param>
        /// <returns>Detailed information about the video</returns>
        [HttpGet("video/{videoId}")]
        public async Task<ActionResult<object>> GetVideoDetails(string videoId)
        {
            if (string.IsNullOrEmpty(videoId))
            {
                return BadRequest(new { success = false, message = "Video ID is required" });
            }

            try
            {
                var video = await _youtubeService.GetVideoDetailsAsync(videoId);
                if (video == null)
                {
                    return NotFound(new { success = false, message = "Video not found" });
                }

                return Ok(new { success = true, data = video });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get recommended videos for a tournament based on sport and tournament name
        /// </summary>
        /// <param name="tournamentName">Tournament name</param>
        /// <param name="sportName">Sport name</param>
        /// <param name="maxResults">Maximum number of results (default: 5)</param>
        /// <returns>List of recommended videos</returns>
        [HttpGet("recommended")]
        public async Task<ActionResult<object>> GetRecommendedVideos(
            [FromQuery] string tournamentName,
            [FromQuery] string sportName,
            [FromQuery] int maxResults = 5)
        {
            if (string.IsNullOrEmpty(tournamentName) || string.IsNullOrEmpty(sportName))
            {
                return BadRequest(new 
                { 
                    success = false, 
                    message = "Tournament name and sport name are required" 
                });
            }

            try
            {
                var result = await _youtubeService.GetRecommendedVideosAsync(
                    tournamentName, sportName, maxResults);
                return Ok(new 
                { 
                    success = true, 
                    data = result,
                    tournament = tournamentName,
                    sport = sportName,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get recommended videos for a specific tournament by ID
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <param name="maxResults">Maximum number of results (default: 5)</param>
        /// <returns>List of recommended videos for the tournament</returns>
        [HttpGet("tournament/{tournamentId}/recommended")]
        public async Task<ActionResult<object>> GetTournamentRecommendedVideos(
            int tournamentId,
            [FromQuery] int maxResults = 5)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new { success = false, message = "Tournament not found" });
                }

                var sportName = tournament.Sports?.Name ?? "Sports";
                var result = await _youtubeService.GetRecommendedVideosAsync(
                    tournament.Name, sportName, maxResults);

                return Ok(new 
                { 
                    success = true, 
                    data = result,
                    tournamentId = tournamentId,
                    tournamentName = tournament.Name,
                    sport = sportName,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error fetching recommended videos", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get videos associated with a specific match
        /// </summary>
        /// <param name="matchId">Match ID</param>
        /// <returns>Match video information (highlights and livestream)</returns>
        [HttpGet("match/{matchId}")]
        public async Task<ActionResult<object>> GetMatchVideos(int matchId)
        {
            try
            {
                var match = await _context.Matches
                    .Include(m => m.Tournament)
                        .ThenInclude(t => t.Sports)
                    .FirstOrDefaultAsync(m => m.Id == matchId);

                if (match == null)
                {
                    return NotFound(new { success = false, message = "Match not found" });
                }

                var response = new
                {
                    success = true,
                    matchId = match.Id,
                    teamA = match.TeamA,
                    teamB = match.TeamB,
                    matchDate = match.MatchDate,
                    tournamentName = match.Tournament?.Name,
                    sportName = match.Tournament?.Sports?.Name,
                    videos = new
                    {
                        highlightsUrl = match.HighlightsVideoUrl,
                        highlightsVideoId = !string.IsNullOrEmpty(match.HighlightsVideoUrl) 
                            ? _youtubeService.ExtractVideoIdFromUrl(match.HighlightsVideoUrl) 
                            : null,
                        liveStreamUrl = match.LiveStreamUrl,
                        liveStreamVideoId = !string.IsNullOrEmpty(match.LiveStreamUrl) 
                            ? _youtubeService.ExtractVideoIdFromUrl(match.LiveStreamUrl) 
                            : null,
                        description = match.VideoDescription
                    }
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error fetching match videos", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Update match video URLs (Admin only)
        /// </summary>
        /// <param name="matchId">Match ID</param>
        /// <param name="request">Video update request containing URLs and description</param>
        /// <returns>Updated match video information</returns>
        [HttpPost("match/{matchId}/video")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<object>> UpdateMatchVideo(
            int matchId,
            [FromBody] UpdateMatchVideoRequest request)
        {
            try
            {
                var match = await _context.Matches.FindAsync(matchId);
                if (match == null)
                {
                    return NotFound(new { success = false, message = "Match not found" });
                }

                // Validate YouTube URLs
                if (!string.IsNullOrEmpty(request.HighlightsUrl))
                {
                    try
                    {
                        if (!_youtubeService.IsValidYouTubeUrl(request.HighlightsUrl))
                        {
                            return BadRequest(new 
                            { 
                                success = false, 
                                message = "Invalid highlights URL. Must be a valid YouTube URL." 
                            });
                        }
                    }
                    catch
                    {
                        return BadRequest(new 
                        { 
                            success = false, 
                            message = "YouTube service is not available" 
                        });
                    }
                }

                if (!string.IsNullOrEmpty(request.LiveStreamUrl))
                {
                    try
                    {
                        if (!_youtubeService.IsValidYouTubeUrl(request.LiveStreamUrl))
                        {
                            return BadRequest(new 
                            { 
                                success = false, 
                                message = "Invalid live stream URL. Must be a valid YouTube URL." 
                            });
                        }
                    }
                    catch
                    {
                        return BadRequest(new 
                        { 
                            success = false, 
                            message = "YouTube service is not available" 
                        });
                    }
                }

                match.HighlightsVideoUrl = request.HighlightsUrl;
                match.LiveStreamUrl = request.LiveStreamUrl;
                match.VideoDescription = request.Description;

                await _context.SaveChangesAsync();

                return Ok(new 
                { 
                    success = true, 
                    message = "Video URLs updated successfully",
                    data = new
                    {
                        matchId = match.Id,
                        highlightsUrl = match.HighlightsVideoUrl,
                        highlightsVideoId = !string.IsNullOrEmpty(match.HighlightsVideoUrl) 
                            ? _youtubeService.ExtractVideoIdFromUrl(match.HighlightsVideoUrl) 
                            : null,
                        liveStreamUrl = match.LiveStreamUrl,
                        liveStreamVideoId = !string.IsNullOrEmpty(match.LiveStreamUrl) 
                            ? _youtubeService.ExtractVideoIdFromUrl(match.LiveStreamUrl) 
                            : null,
                        description = match.VideoDescription
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error updating match video", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Extract video ID from YouTube URL
        /// </summary>
        /// <param name="url">YouTube video URL</param>
        /// <returns>Extracted video ID</returns>
        [HttpGet("extract-video-id")]
        public ActionResult<object> ExtractVideoId([FromQuery] string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return BadRequest(new { success = false, message = "URL is required" });
            }

            try
            {
                var videoId = _youtubeService.ExtractVideoIdFromUrl(url);
                if (string.IsNullOrEmpty(videoId))
                {
                    return BadRequest(new 
                    { 
                        success = false, 
                        message = "Invalid YouTube URL. Unable to extract video ID." 
                    });
                }

                return Ok(new 
                { 
                    success = true, 
                    videoId = videoId,
                    embedUrl = $"https://www.youtube.com/embed/{videoId}",
                    watchUrl = $"https://www.youtube.com/watch?v={videoId}",
                    thumbnailUrl = $"https://img.youtube.com/vi/{videoId}/maxresdefault.jpg"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error extracting video ID", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Validate YouTube URL
        /// </summary>
        /// <param name="url">YouTube URL to validate</param>
        /// <returns>Validation result</returns>
        [HttpGet("validate-url")]
        public ActionResult<object> ValidateUrl([FromQuery] string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return BadRequest(new { success = false, message = "URL is required" });
            }

            try
            {
                var isValid = _youtubeService.IsValidYouTubeUrl(url);
                var videoId = isValid ? _youtubeService.ExtractVideoIdFromUrl(url) : null;

                return Ok(new 
                { 
                    success = true,
                    isValid = isValid,
                    url = url,
                    videoId = videoId,
                    embedUrl = isValid ? $"https://www.youtube.com/embed/{videoId}" : null
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube service is not available", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Search match-related videos
        /// </summary>
        /// <param name="matchId">Match ID</param>
        /// <param name="maxResults">Maximum results (default: 5)</param>
        /// <returns>Search results for match-related videos</returns>
        [HttpGet("match/{matchId}/search")]
        public async Task<ActionResult<object>> SearchMatchVideos(
            int matchId,
            [FromQuery] int maxResults = 5)
        {
            try
            {
                var match = await _context.Matches
                    .Include(m => m.Tournament)
                        .ThenInclude(t => t.Sports)
                    .FirstOrDefaultAsync(m => m.Id == matchId);

                if (match == null)
                {
                    return NotFound(new { success = false, message = "Match not found" });
                }

                // Build search query
                var sportName = match.Tournament?.Sports?.Name ?? "Sports";
                var query = $"{match.TeamA} vs {match.TeamB} {sportName} highlights";

                var result = await _youtubeService.SearchHighlightsAsync(query, maxResults);

                return Ok(new 
                { 
                    success = true,
                    matchId = matchId,
                    teamA = match.TeamA,
                    teamB = match.TeamB,
                    sport = sportName,
                    query = query,
                    data = result,
                    count = result?.Videos?.Count ?? 0
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error searching match videos", 
                    error = ex.Message 
                });
            }
        }
    }

    /// <summary>
    /// Request model for updating match video URLs
    /// </summary>
    public class UpdateMatchVideoRequest
    {
        /// <summary>
        /// YouTube URL for match highlights
        /// </summary>
        public string? HighlightsUrl { get; set; }

        /// <summary>
        /// YouTube URL for live stream
        /// </summary>
        public string? LiveStreamUrl { get; set; }

        /// <summary>
        /// Description or notes about the videos
        /// </summary>
        public string? Description { get; set; }
    }
}
