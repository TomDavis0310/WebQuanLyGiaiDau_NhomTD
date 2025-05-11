﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class TournamentSubmission
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        [Required]
        public int TournamentId { get; set; }
        public Tournament Tournament { get; set; }

        [DataType(DataType.Date)]
        public DateTime SubmissionDate { get; set; } = DateTime.Now;

        [Required(ErrorMessage = "Vui lòng nhập tiêu đề bài viết")]
        [StringLength(200, ErrorMessage = "Tiêu đề không được vượt quá 200 ký tự")]
        public string Title { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập nội dung bài viết")]
        public string Content { get; set; }

        // Đường dẫn đến file đính kèm (nếu có)
        public string? FileUrl { get; set; }

        // Tên gốc của file đính kèm
        public string? FileName { get; set; }

        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
        
        public string? AdminNotes { get; set; } // Ghi chú của admin khi duyệt/từ chối
    }
}
