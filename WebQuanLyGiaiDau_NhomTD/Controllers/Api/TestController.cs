using Microsoft.AspNetCore.Mvc;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestController : ControllerBase
    {
        private readonly ILogger<TestController> _logger;

        public TestController(ILogger<TestController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Test endpoint để kiểm tra Global Exception Handler
        /// </summary>
        [HttpGet("error")]
        public IActionResult TestError()
        {
            _logger.LogInformation("Testing global exception handler...");
            throw new InvalidOperationException("This is a test exception to verify global exception handling works correctly!");
        }

        /// <summary>
        /// Test endpoint để kiểm tra ArgumentException
        /// </summary>
        [HttpGet("argument-error")]
        public IActionResult TestArgumentError()
        {
            _logger.LogInformation("Testing argument exception...");
            throw new ArgumentException("This is a test argument exception with invalid parameter!", "testParam");
        }

        /// <summary>
        /// Test endpoint để kiểm tra UnauthorizedAccessException
        /// </summary>
        [HttpGet("unauthorized-error")]
        public IActionResult TestUnauthorizedError()
        {
            _logger.LogInformation("Testing unauthorized exception...");
            throw new UnauthorizedAccessException("This is a test unauthorized access exception!");
        }

        /// <summary>
        /// Test endpoint để kiểm tra NotImplementedException
        /// </summary>
        [HttpGet("not-implemented")]
        public IActionResult TestNotImplemented()
        {
            _logger.LogInformation("Testing not implemented exception...");
            throw new NotImplementedException("This feature is not implemented yet!");
        }

        /// <summary>
        /// Test endpoint normal response
        /// </summary>
        [HttpGet("success")]
        public IActionResult TestSuccess()
        {
            _logger.LogInformation("Test success endpoint called");
            return Ok(new { 
                message = "Test endpoint is working correctly!",
                timestamp = DateTime.UtcNow,
                status = "success"
            });
        }
    }
}