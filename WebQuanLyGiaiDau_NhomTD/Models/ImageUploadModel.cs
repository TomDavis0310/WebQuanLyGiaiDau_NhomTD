using Microsoft.AspNetCore.Http;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class ImageUploadModel
    {
        public IFormFile File { get; set; }
        public string UploadType { get; set; }
    }
}
