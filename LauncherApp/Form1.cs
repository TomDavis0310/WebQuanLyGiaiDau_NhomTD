using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace TDSportsLauncher;

public partial class Form1 : Form
{
    private Process? _serverProcess;
    private Process? _clientProcess;
    private readonly string _serverPath;
    private readonly string _clientPath;
    private RichTextBox _logBox;
    private Button _btnStartServer;
    private Button _btnStartClientWeb;
    private Button _btnStartClientWin;
    private Button _btnStopAll;
    private ToolStripStatusLabel _statusLabel;

    public Form1()
    {
        // InitializeComponent(); // Skipping standard designer init to build custom UI
        
        // Setup paths
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string rootDir = FindRootDirectory(baseDir);
        
        _serverPath = Path.Combine(rootDir, "WebQuanLyGiaiDau_NhomTD");
        _clientPath = Path.Combine(rootDir, "tournament_app");

        InitializeCustomUI();
        
        Log($"Root Directory detected: {rootDir}");
        Log($"Server Path: {_serverPath}");
        Log($"Client Path: {_clientPath}");
    }

    private string FindRootDirectory(string startPath)
    {
        DirectoryInfo? dir = new DirectoryInfo(startPath);
        while (dir != null)
        {
            if (Directory.Exists(Path.Combine(dir.FullName, "WebQuanLyGiaiDau_NhomTD")) && 
                Directory.Exists(Path.Combine(dir.FullName, "tournament_app")))
            {
                return dir.FullName;
            }
            dir = dir.Parent;
        }
        return "C:\\dacn\\WebQuanLyGiaiDau_NhomTD"; // Fallback
    }

    private void InitializeCustomUI()
    {
        this.Text = "TD Sports Launcher";
        this.Size = new Size(900, 600);
        this.StartPosition = FormStartPosition.CenterScreen;
        this.BackColor = Color.FromArgb(240, 242, 245);
        this.Font = new Font("Segoe UI", 10);
        this.Icon = SystemIcons.Application;

        // Header
        Panel headerPanel = new Panel
        {
            Dock = DockStyle.Top,
            Height = 80,
            BackColor = Color.FromArgb(25, 118, 210)
        };
        Label titleLabel = new Label
        {
            Text = "TD Sports Management System",
            ForeColor = Color.White,
            Font = new Font("Segoe UI", 18, FontStyle.Bold),
            AutoSize = true,
            Location = new Point(20, 20)
        };
        Label subtitleLabel = new Label
        {
            Text = "Server & Client Launcher",
            ForeColor = Color.FromArgb(200, 255, 255, 255),
            Font = new Font("Segoe UI", 10),
            AutoSize = true,
            Location = new Point(22, 50)
        };
        headerPanel.Controls.Add(titleLabel);
        headerPanel.Controls.Add(subtitleLabel);
        this.Controls.Add(headerPanel);

        // Controls Panel
        Panel controlsPanel = new Panel
        {
            Dock = DockStyle.Top,
            Height = 100,
            Padding = new Padding(20),
            BackColor = Color.White
        };

        _btnStartServer = CreateButton("Start Server", 20, 30, Color.FromArgb(76, 175, 80));
        _btnStartServer.Click += (s, e) => StartServer();

        _btnStartClientWeb = CreateButton("Client (Edge)", 180, 30, Color.FromArgb(33, 150, 243));
        _btnStartClientWeb.Click += (s, e) => StartClient("edge");

        _btnStartClientWin = CreateButton("Open Web Admin", 340, 30, Color.FromArgb(255, 152, 0));
        _btnStartClientWin.Click += (s, e) => OpenWebAdmin();
        // _btnStartClientWin.Enabled = false; // Re-enabled for user to try
        // _btnStartClientWin.BackColor = Color.Gray;
        // _btnStartClientWin.Text = "Win (Missing C++)";

        _btnStopAll = CreateButton("Stop All", 500, 30, Color.FromArgb(244, 67, 54));
        _btnStopAll.Click += (s, e) => StopAll();
        _btnStopAll.Enabled = false;
        
        Button _btnOpenCode = CreateButton("Open VS Code", 660, 30, Color.FromArgb(96, 125, 139));
        _btnOpenCode.Click += (s, e) => OpenVSCode();

        Button _btnDevMode = CreateButton("Fix Symlink", 660, 80, Color.Orange);
        _btnDevMode.Click += (s, e) => OpenDevSettings();

        controlsPanel.Controls.AddRange(new Control[] { _btnStartServer, _btnStartClientWeb, _btnStartClientWin, _btnStopAll, _btnOpenCode, _btnDevMode });
        this.Controls.Add(controlsPanel);

        // Status Strip
        StatusStrip statusStrip = new StatusStrip();
        _statusLabel = new ToolStripStatusLabel("Ready");
        statusStrip.Items.Add(_statusLabel);
        this.Controls.Add(statusStrip);

        // Log Area
        _logBox = new RichTextBox
        {
            Dock = DockStyle.Fill,
            BackColor = Color.FromArgb(30, 30, 30),
            ForeColor = Color.LightGray,
            Font = new Font("Consolas", 10),
            ReadOnly = true,
            BorderStyle = BorderStyle.None,
            Padding = new Padding(10)
        };
        this.Controls.Add(_logBox);
        _logBox.BringToFront(); // Ensure it's visible
    }

    private Button CreateButton(string text, int x, int y, Color color)
    {
        Button btn = new Button
        {
            Text = text,
            Location = new Point(x, y),
            Size = new Size(140, 40),
            FlatStyle = FlatStyle.Flat,
            BackColor = color,
            ForeColor = Color.White,
            Cursor = Cursors.Hand,
            Font = new Font("Segoe UI", 9, FontStyle.Bold)
        };
        btn.FlatAppearance.BorderSize = 0;
        return btn;
    }

    private void Log(string message)
    {
        if (InvokeRequired)
        {
            Invoke(new Action(() => Log(message)));
            return;
        }
        _logBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}\n");
        _logBox.ScrollToCaret();
    }

    private void StartServer()
    {
        if (_serverProcess != null && !_serverProcess.HasExited)
        {
            Log("Server is already running.");
            return;
        }

        if (!Directory.Exists(_serverPath))
        {
            Log($"Error: Server path not found: {_serverPath}");
            return;
        }

        Log($"Starting Server...");
        
        ProcessStartInfo psi = new ProcessStartInfo
        {
            FileName = "dotnet",
            Arguments = "run",
            WorkingDirectory = _serverPath,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        
        // Set environment variables if needed
        psi.EnvironmentVariables["ASPNETCORE_ENVIRONMENT"] = "Development";
        psi.EnvironmentVariables["PORT"] = "5194"; // Force port 5194 to match launchSettings and avoid 8080 conflict

        _serverProcess = new Process { StartInfo = psi };
        _serverProcess.OutputDataReceived += (s, e) => { if (!string.IsNullOrEmpty(e.Data)) Log($"[Server] {e.Data}"); };
        _serverProcess.ErrorDataReceived += (s, e) => { if (!string.IsNullOrEmpty(e.Data)) Log($"[Server Error] {e.Data}"); };

        try
        {
            _serverProcess.Start();
            _serverProcess.BeginOutputReadLine();
            _serverProcess.BeginErrorReadLine();
            Log("Server process started.");
            _btnStartServer.Enabled = false;
            _btnStartServer.BackColor = Color.Gray;
            _btnStopAll.Enabled = true;
            _statusLabel.Text = "Server Running";
        }
        catch (Exception ex)
        {
            Log($"Error starting server: {ex.Message}");
        }
    }

    private void StartClient(string device)
    {
        if (!Directory.Exists(_clientPath))
        {
            Log($"Error: Client path not found: {_clientPath}");
            return;
        }

        Log($"Starting Client ({device})...");

        ProcessStartInfo psi;
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c flutter run -d {device} --web-renderer html",
                WorkingDirectory = _clientPath,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
        }
        else
        {
            psi = new ProcessStartInfo
            {
                FileName = "flutter",
                Arguments = $"run -d {device}",
                WorkingDirectory = _clientPath,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
        }

        var clientProcess = new Process { StartInfo = psi };
        clientProcess.OutputDataReceived += (s, e) => { if (!string.IsNullOrEmpty(e.Data)) Log($"[Client] {e.Data}"); };
        clientProcess.ErrorDataReceived += (s, e) => { if (!string.IsNullOrEmpty(e.Data)) Log($"[Client Error] {e.Data}"); };

        try
        {
            clientProcess.Start();
            clientProcess.BeginOutputReadLine();
            clientProcess.BeginErrorReadLine();
            Log($"Client ({device}) process started.");
            _clientProcess = clientProcess; 
            _btnStopAll.Enabled = true;
        }
        catch (Exception ex)
        {
            Log($"Error starting client: {ex.Message}");
            Log("Make sure 'flutter' is in your system PATH.");
        }
    }
    
    private void OpenVSCode()
    {
        try 
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "code",
                Arguments = ".",
                WorkingDirectory = Path.GetDirectoryName(_serverPath), // Open near server
                UseShellExecute = true
            });
        }
        catch(Exception ex)
        {
            Log($"Could not open VS Code: {ex.Message}");
        }
    }

    private void OpenDevSettings()
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c start ms-settings:developers",
                UseShellExecute = true,
                CreateNoWindow = true
            });
            Log("Opened Developer Settings. Please enable 'Developer Mode'.");
        }
        catch (Exception ex)
        {
            Log($"Error opening settings: {ex.Message}");
        }
    }

    private void OpenWebAdmin()
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c start http://localhost:5194",
                UseShellExecute = true,
                CreateNoWindow = true
            });
            Log("Opened Web Admin (http://localhost:5194)");
        }
        catch (Exception ex)
        {
            Log($"Error opening Web Admin: {ex.Message}");
        }
    }

    private void StopAll()
    {
        if (_serverProcess != null && !_serverProcess.HasExited)
        {
            Log("Stopping Server...");
            try { 
                // Try to kill the process tree if possible, but Kill() is usually enough for dotnet run
                _serverProcess.Kill(); 
            } catch (Exception ex) { Log($"Error stopping server: {ex.Message}"); }
            _serverProcess = null;
            _btnStartServer.Enabled = true;
            _btnStartServer.BackColor = Color.FromArgb(76, 175, 80);
        }

        if (_clientProcess != null && !_clientProcess.HasExited)
        {
            Log("Stopping Client...");
            try { _clientProcess.Kill(); } catch (Exception ex) { Log($"Error stopping client: {ex.Message}"); }
            _clientProcess = null;
        }
        
        Log("All processes stopped.");
        _btnStopAll.Enabled = false;
        _statusLabel.Text = "Stopped";
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        StopAll();
        base.OnFormClosing(e);
    }
}
