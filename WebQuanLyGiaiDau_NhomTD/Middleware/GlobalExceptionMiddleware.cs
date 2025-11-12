using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace WebQuanLyGiaiDau_NhomTD.Middleware
{
    /// <summary>
    /// Global Exception Handling Middleware để xử lý tất cả exception trong ứng dụng
    /// </summary>
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;

        public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception occurred. RequestId: {RequestId}", context.TraceIdentifier);
                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var response = context.Response;
            response.ContentType = "application/json";
            
            var responseModel = new ErrorResponse
            {
                RequestId = context.TraceIdentifier,
                Timestamp = DateTime.UtcNow
            };

            switch (exception)
            {
                case ArgumentException ex:
                    responseModel.Message = ex.Message;
                    responseModel.StatusCode = (int)HttpStatusCode.BadRequest;
                    response.StatusCode = (int)HttpStatusCode.BadRequest;
                    break;

                case KeyNotFoundException ex:
                    responseModel.Message = "Resource not found";
                    responseModel.StatusCode = (int)HttpStatusCode.NotFound;
                    response.StatusCode = (int)HttpStatusCode.NotFound;
                    break;

                case UnauthorizedAccessException ex:
                    responseModel.Message = "Unauthorized access";
                    responseModel.StatusCode = (int)HttpStatusCode.Unauthorized;
                    response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    break;

                case TimeoutException ex:
                    responseModel.Message = "Request timeout";
                    responseModel.StatusCode = (int)HttpStatusCode.RequestTimeout;
                    response.StatusCode = (int)HttpStatusCode.RequestTimeout;
                    break;

                default:
                    responseModel.Message = "An internal server error occurred";
                    responseModel.StatusCode = (int)HttpStatusCode.InternalServerError;
                    response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    break;
            }

            // Nếu là API request, trả về JSON
            if (IsApiRequest(context))
            {
                var jsonResponse = JsonSerializer.Serialize(responseModel, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                });
                
                await response.WriteAsync(jsonResponse);
            }
            else
            {
                // Nếu là MVC request, redirect đến error page
                context.Response.Redirect($"/Home/Error?requestId={responseModel.RequestId}&statusCode={responseModel.StatusCode}");
            }
        }

        private static bool IsApiRequest(HttpContext context)
        {
            return context.Request.Path.StartsWithSegments("/api") ||
                   context.Request.Headers["Accept"].ToString().Contains("application/json") ||
                   context.Request.ContentType?.Contains("application/json") == true;
        }
    }

    /// <summary>
    /// Error Response Model for API responses
    /// </summary>
    public class ErrorResponse
    {
        public string Message { get; set; } = string.Empty;
        public int StatusCode { get; set; }
        public string RequestId { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
        public object? Details { get; set; }
    }
}