using System.Diagnostics;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        if (User.Identity.IsAuthenticated)
        {
            if (User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                return View("AdminDashboard");
            }
            else if (User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User))
            {
                return View("UserDashboard");
            }
        }
        return View();
    }

    [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
    public IActionResult AdminDashboard()
    {
        return View();
    }

    [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
    public IActionResult UserDashboard()
    {
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
