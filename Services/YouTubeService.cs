using Google.Apis.Services;
using Google.Apis.YouTube.v3;
using Google.Apis.YouTube.v3.Data;
using System.Text.RegularExpressions;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public class YouTubeService : IYouTubeService
    {
        private readonly Google.Apis.YouTube.v3.YouTubeService _youtubeService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<YouTubeService> _logger;

        public YouTubeService(IConfiguration configuration, ILogger<YouTubeService> logger)
        {
            _configuration = configuration;
            _logger = logger;

            var apiKey = _configuration["YouTube:ApiKey"];
            if (string.IsNullOrEmpty(apiKey))
            {
                throw new InvalidOperationException("YouTube API key is not configured");
            }

            _youtubeService = new Google.Apis.YouTube.v3.YouTubeService(new BaseClientService.Initializer()
            {
                ApiKey = apiKey,
                ApplicationName = "Sports Tournament Management"
            });
        }

        public async Task<YouTubeSearchResponse> SearchVideosAsync(YouTubeSearchRequest request)
        {
            try
            {
                var searchListRequest = _youtubeService.Search.List("snippet");
                searchListRequest.Q = request.Query;
                searchListRequest.MaxResults = request.MaxResults;
                searchListRequest.Order = GetSearchOrder(request.Order);
                searchListRequest.Type = request.Type;

                if (request.LiveOnly)
                {
                    searchListRequest.EventType = SearchResource.ListRequest.EventTypeEnum.Live;
                }

                var searchListResponse = await searchListRequest.ExecuteAsync();

                var videos = new List<YouTubeVideo>();
                foreach (var searchResult in searchListResponse.Items)
                {
                    if (searchResult.Id.Kind == "youtube#video")
                    {
                        var video = await ConvertToYouTubeVideo(searchResult);
                        videos.Add(video);
                    }
                }

                return new YouTubeSearchResponse
                {
                    Videos = videos,
                    NextPageToken = searchListResponse.NextPageToken,
                    PrevPageToken = searchListResponse.PrevPageToken,
                    TotalResults = (int)(searchListResponse.PageInfo.TotalResults ?? 0)
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching YouTube videos for query: {Query}", request.Query);
                return new YouTubeSearchResponse();
            }
        }

        public async Task<YouTubeVideo> GetVideoDetailsAsync(string videoId)
        {
            try
            {
                var videoRequest = _youtubeService.Videos.List("snippet,statistics,contentDetails,liveStreamingDetails");
                videoRequest.Id = videoId;

                var videoResponse = await videoRequest.ExecuteAsync();
                var videoItem = videoResponse.Items.FirstOrDefault();

                if (videoItem == null)
                    return null;

                return ConvertToYouTubeVideoFromVideoItem(videoItem);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting video details for ID: {VideoId}", videoId);
                return null;
            }
        }

        public async Task<YouTubeSearchResponse> SearchLiveStreamsAsync(string query, int maxResults = 10)
        {
            var request = new YouTubeSearchRequest
            {
                Query = query + " live stream",
                MaxResults = maxResults,
                Order = "date",
                LiveOnly = true
            };

            return await SearchVideosAsync(request);
        }

        public async Task<YouTubeSearchResponse> SearchHighlightsAsync(string query, int maxResults = 10)
        {
            var request = new YouTubeSearchRequest
            {
                Query = query + " highlights",
                MaxResults = maxResults,
                Order = "relevance"
            };

            return await SearchVideosAsync(request);
        }

        public string ExtractVideoIdFromUrl(string youtubeUrl)
        {
            if (string.IsNullOrEmpty(youtubeUrl))
                return null;

            // Regular expressions for different YouTube URL formats
            var patterns = new[]
            {
                @"(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})",
                @"youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]{11})"
            };

            foreach (var pattern in patterns)
            {
                var match = Regex.Match(youtubeUrl, pattern);
                if (match.Success)
                {
                    return match.Groups[1].Value;
                }
            }

            return null;
        }

        public bool IsValidYouTubeUrl(string url)
        {
            if (string.IsNullOrEmpty(url))
                return false;

            return !string.IsNullOrEmpty(ExtractVideoIdFromUrl(url));
        }

        public async Task<YouTubeSearchResponse> GetRecommendedVideosAsync(string tournamentName, string sportName, int maxResults = 5)
        {
            var query = $"{sportName} {tournamentName} tournament highlights";
            var request = new YouTubeSearchRequest
            {
                Query = query,
                MaxResults = maxResults,
                Order = "relevance"
            };

            return await SearchVideosAsync(request);
        }

        private SearchResource.ListRequest.OrderEnum GetSearchOrder(string order)
        {
            return order.ToLower() switch
            {
                "date" => SearchResource.ListRequest.OrderEnum.Date,
                "rating" => SearchResource.ListRequest.OrderEnum.Rating,
                "viewcount" => SearchResource.ListRequest.OrderEnum.ViewCount,
                "title" => SearchResource.ListRequest.OrderEnum.Title,
                _ => SearchResource.ListRequest.OrderEnum.Relevance
            };
        }

        private async Task<YouTubeVideo> ConvertToYouTubeVideo(SearchResult searchResult)
        {
            var video = new YouTubeVideo
            {
                VideoId = searchResult.Id.VideoId,
                Title = searchResult.Snippet.Title,
                Description = searchResult.Snippet.Description,
                ThumbnailUrl = searchResult.Snippet.Thumbnails?.Medium?.Url ?? searchResult.Snippet.Thumbnails?.Default__?.Url,
                ChannelTitle = searchResult.Snippet.ChannelTitle,
                PublishedAt = searchResult.Snippet.PublishedAt ?? DateTime.MinValue
            };

            // Get additional details
            var videoDetails = await GetVideoDetailsAsync(video.VideoId);
            if (videoDetails != null)
            {
                video.Duration = videoDetails.Duration;
                video.ViewCount = videoDetails.ViewCount;
                video.IsLiveStream = videoDetails.IsLiveStream;
                video.LiveStatus = videoDetails.LiveStatus;
            }

            return video;
        }

        private YouTubeVideo ConvertToYouTubeVideoFromVideoItem(Video videoItem)
        {
            var isLive = videoItem.LiveStreamingDetails != null;
            var liveStatus = "none";

            if (isLive)
            {
                if (videoItem.LiveStreamingDetails.ActualStartTime.HasValue && !videoItem.LiveStreamingDetails.ActualEndTime.HasValue)
                    liveStatus = "live";
                else if (videoItem.LiveStreamingDetails.ScheduledStartTime.HasValue && !videoItem.LiveStreamingDetails.ActualStartTime.HasValue)
                    liveStatus = "upcoming";
            }

            return new YouTubeVideo
            {
                VideoId = videoItem.Id,
                Title = videoItem.Snippet.Title,
                Description = videoItem.Snippet.Description,
                ThumbnailUrl = videoItem.Snippet.Thumbnails?.Medium?.Url ?? videoItem.Snippet.Thumbnails?.Default__?.Url,
                ChannelTitle = videoItem.Snippet.ChannelTitle,
                PublishedAt = videoItem.Snippet.PublishedAt ?? DateTime.MinValue,
                Duration = videoItem.ContentDetails?.Duration ?? "PT0S",
                ViewCount = (long)(videoItem.Statistics?.ViewCount ?? 0),
                IsLiveStream = isLive,
                LiveStatus = liveStatus
            };
        }

        public void Dispose()
        {
            _youtubeService?.Dispose();
        }
    }
}
