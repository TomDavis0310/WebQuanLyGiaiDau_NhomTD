namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class ErrorViewModel
    {
        public string? RequestId { get; set; }
        public int StatusCode { get; set; } = 500;
        public string? ErrorMessage { get; set; }

        public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);
        
        public string GetStatusCodeMessage()
        {
            return StatusCode switch
            {
                400 => "Bad Request - Yêu cầu không hợp lệ",
                401 => "Unauthorized - Không có quyền truy cập",
                403 => "Forbidden - Truy cập bị từ chối",
                404 => "Not Found - Không tìm thấy trang",
                408 => "Request Timeout - Yêu cầu hết thời gian",
                500 => "Internal Server Error - Lỗi máy chủ nội bộ",
                502 => "Bad Gateway - Lỗi gateway",
                503 => "Service Unavailable - Dịch vụ không khả dụng",
                _ => "Đã xảy ra lỗi"
            };
        }
    }
}
