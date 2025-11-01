# 📅 Tournament Schedule API Documentation

## Base URL
```
http://localhost:8080/api/tournament-management
```

## Endpoints

### 1. Generate Tournament Schedule (Admin Only)
Automatically generate a complete match schedule for a tournament based on registered teams.

**Endpoint:** `POST /api/tournament-management/{tournamentId}/generate-schedule`

**Authentication:** Required (Admin role)

**Parameters:**
- `tournamentId` (path parameter): Tournament ID

**Example:**
```bash
POST /api/tournament-management/1/generate-schedule
Authorization: Bearer YOUR_JWT_TOKEN
```

**Response:**
```json
{
  "success": true,
  "message": "Đã tạo 15 trận đấu thành công",
  "data": {
    "tournamentId": 1,
    "tournamentName": "Giải Bóng Rổ 3v3 Mùa Thu 2024",
    "totalTeams": 6,
    "totalMatches": 15,
    "startDate": "2024-12-01T00:00:00",
    "endDate": "2024-12-08T00:00:00",
    "matches": [
      {
        "matchId": 101,
        "teamA": "Team A",
        "teamB": "Team B",
        "matchDate": "2024-12-01T00:00:00",
        "matchTime": "15:00:00",
        "location": "Nhà thi đấu Hoa Lư"
      },
      {
        "matchId": 102,
        "teamA": "Team C",
        "teamB": "Team D",
        "matchDate": "2024-12-01T00:00:00",
        "matchTime": "17:00:00",
        "location": "Nhà thi đấu Hoa Lư"
      }
    ]
  },
  "count": 15
}
```

---

### 2. Get Tournament Schedule
Retrieve the complete schedule for a tournament with all match details.

**Endpoint:** `GET /api/tournament-management/{tournamentId}/schedule`

**Parameters:**
- `tournamentId` (path parameter): Tournament ID

**Example:**
```bash
GET /api/tournament-management/1/schedule
```

**Response:**
```json
{
  "success": true,
  "message": "Lấy lịch thi đấu thành công",
  "data": {
    "tournamentId": 1,
    "tournamentName": "Giải Bóng Rổ 3v3 Mùa Thu 2024",
    "sportName": "Bóng Rổ",
    "location": "Nhà thi đấu Hoa Lư",
    "startDate": "2024-12-01T00:00:00",
    "endDate": "2024-12-15T00:00:00",
    "totalMatches": 15,
    "completedMatches": 5,
    "upcomingMatches": 10,
    "matches": [
      {
        "matchId": 101,
        "teamA": "Team A",
        "teamAId": 1,
        "teamB": "Team B",
        "teamBId": 2,
        "scoreA": 21,
        "scoreB": 18,
        "matchDate": "2024-12-01T00:00:00",
        "matchTime": "15:00:00",
        "location": "Nhà thi đấu Hoa Lư",
        "status": "Đã kết thúc",
        "highlightsUrl": "https://youtube.com/watch?v=abc123",
        "liveStreamUrl": null
      },
      {
        "matchId": 102,
        "teamA": "Team C",
        "teamAId": 3,
        "teamB": "Team D",
        "teamBId": 4,
        "scoreA": null,
        "scoreB": null,
        "matchDate": "2024-12-05T00:00:00",
        "matchTime": "17:00:00",
        "location": "Nhà thi đấu Hoa Lư",
        "status": "Sắp diễn ra",
        "highlightsUrl": null,
        "liveStreamUrl": null
      }
    ]
  },
  "count": 15
}
```

---

## How Schedule Generation Works

### 1. **Round Robin Format**
The system generates a complete round-robin schedule where each team plays every other team exactly once.

**Formula:**
- Number of matches = n × (n - 1) / 2
- Where n = number of teams

**Example:**
- 6 teams = 15 matches
- 8 teams = 28 matches
- 4 teams = 6 matches

### 2. **Match Scheduling**
- **2 matches per day** by default
- First match: 3:00 PM (15:00)
- Second match: 5:00 PM (17:00)
- Matches continue daily until all are scheduled

### 3. **Prerequisites**
Before generating a schedule:
- Tournament must exist
- At least 2 teams must be registered
- Teams must have "Approved" status
- Admin authentication required

### 4. **Regeneration**
- Calling generate-schedule again will **delete all existing matches** and create new ones
- Use with caution if matches have already been played
- Scores and match data will be lost

---

## Error Responses

### Tournament Not Found
```json
{
  "success": false,
  "message": "Không tìm thấy giải đấu"
}
```

### Insufficient Teams
```json
{
  "success": false,
  "message": "Giải đấu cần ít nhất 2 đội để tạo lịch thi đấu"
}
```

### Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

### Server Error
```json
{
  "success": false,
  "message": "Có lỗi xảy ra khi tạo lịch thi đấu",
  "error": "Detailed error message"
}
```

---

## Flutter Integration Example

### 1. Generate Schedule (Admin)
```dart
class TournamentScheduleService {
  final Dio dio;
  
  TournamentScheduleService(this.dio);
  
  Future<ScheduleGenerationResult> generateSchedule(
    int tournamentId,
    String adminToken,
  ) async {
    try {
      final response = await dio.post(
        '/api/tournament-management/$tournamentId/generate-schedule',
        options: Options(
          headers: {
            'Authorization': 'Bearer $adminToken',
          },
        ),
      );
      
      if (response.data['success']) {
        return ScheduleGenerationResult.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } catch (e) {
      throw Exception('Failed to generate schedule: $e');
    }
  }
}
```

### 2. Get Tournament Schedule
```dart
Future<TournamentSchedule> getTournamentSchedule(int tournamentId) async {
  try {
    final response = await dio.get(
      '/api/tournament-management/$tournamentId/schedule',
    );
    
    if (response.data['success']) {
      return TournamentSchedule.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  } catch (e) {
    throw Exception('Failed to load schedule: $e');
  }
}
```

### 3. Model Classes
```dart
class TournamentSchedule {
  final int tournamentId;
  final String tournamentName;
  final String? sportName;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final int totalMatches;
  final int completedMatches;
  final int upcomingMatches;
  final List<ScheduleMatch> matches;
  
  TournamentSchedule({
    required this.tournamentId,
    required this.tournamentName,
    this.sportName,
    this.location,
    required this.startDate,
    this.endDate,
    required this.totalMatches,
    required this.completedMatches,
    required this.upcomingMatches,
    required this.matches,
  });
  
  factory TournamentSchedule.fromJson(Map<String, dynamic> json) {
    return TournamentSchedule(
      tournamentId: json['tournamentId'],
      tournamentName: json['tournamentName'],
      sportName: json['sportName'],
      location: json['location'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      totalMatches: json['totalMatches'],
      completedMatches: json['completedMatches'],
      upcomingMatches: json['upcomingMatches'],
      matches: (json['matches'] as List)
          .map((m) => ScheduleMatch.fromJson(m))
          .toList(),
    );
  }
}

class ScheduleMatch {
  final int matchId;
  final String teamA;
  final int? teamAId;
  final String teamB;
  final int? teamBId;
  final int? scoreA;
  final int? scoreB;
  final DateTime matchDate;
  final String matchTime;
  final String location;
  final String status;
  final String? highlightsUrl;
  final String? liveStreamUrl;
  
  ScheduleMatch({
    required this.matchId,
    required this.teamA,
    this.teamAId,
    required this.teamB,
    this.teamBId,
    this.scoreA,
    this.scoreB,
    required this.matchDate,
    required this.matchTime,
    required this.location,
    required this.status,
    this.highlightsUrl,
    this.liveStreamUrl,
  });
  
  factory ScheduleMatch.fromJson(Map<String, dynamic> json) {
    return ScheduleMatch(
      matchId: json['matchId'],
      teamA: json['teamA'],
      teamAId: json['teamAId'],
      teamB: json['teamB'],
      teamBId: json['teamBId'],
      scoreA: json['scoreA'],
      scoreB: json['scoreB'],
      matchDate: DateTime.parse(json['matchDate']),
      matchTime: json['matchTime'],
      location: json['location'],
      status: json['status'],
      highlightsUrl: json['highlightsUrl'],
      liveStreamUrl: json['liveStreamUrl'],
    );
  }
  
  bool get isCompleted => status == 'Đã kết thúc';
  bool get isUpcoming => status == 'Sắp diễn ra';
  bool get isLive => status == 'Đang diễn ra';
}
```

---

## UI Implementation Examples

### 1. Schedule Calendar View
```dart
class ScheduleCalendarView extends StatelessWidget {
  final TournamentSchedule schedule;
  
  @override
  Widget build(BuildContext context) {
    // Group matches by date
    final matchesByDate = <DateTime, List<ScheduleMatch>>{};
    for (var match in schedule.matches) {
      final date = DateTime(
        match.matchDate.year,
        match.matchDate.month,
        match.matchDate.day,
      );
      matchesByDate.putIfAbsent(date, () => []).add(match);
    }
    
    return ListView.builder(
      itemCount: matchesByDate.length,
      itemBuilder: (context, index) {
        final date = matchesByDate.keys.elementAt(index);
        final matches = matchesByDate[date]!;
        
        return DateMatchesCard(
          date: date,
          matches: matches,
        );
      },
    );
  }
}
```

### 2. Admin Schedule Generation Button
```dart
class GenerateScheduleButton extends StatelessWidget {
  final int tournamentId;
  final VoidCallback onSuccess;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today),
      label: Text('Tạo lịch thi đấu'),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text(
              'Tạo lịch thi đấu sẽ xóa tất cả trận đấu hiện có. '
              'Bạn có chắc chắn muốn tiếp tục?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xác nhận'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          try {
            final service = context.read<TournamentScheduleService>();
            final result = await service.generateSchedule(
              tournamentId,
              context.read<AuthProvider>().token,
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã tạo ${result.totalMatches} trận đấu'),
                backgroundColor: Colors.green,
              ),
            );
            
            onSuccess();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
```

---

## Best Practices

1. **Check Team Status**: Only generate schedule after all teams are approved
2. **Backup Data**: Consider backing up match data before regenerating
3. **User Confirmation**: Always ask for confirmation before regenerating
4. **Error Handling**: Handle errors gracefully and show user-friendly messages
5. **Loading States**: Show loading indicators during generation
6. **Notifications**: Notify teams when schedule is generated/updated

---

## Testing with Swagger

Access Swagger UI at: `http://localhost:8080/api-docs`

Look for:
- **TournamentManagement** section
- `POST /api/tournament-management/{tournamentId}/generate-schedule`
- `GET /api/tournament-management/{tournamentId}/schedule`

---

## Related APIs

- **Tournament API**: `/api/TournamentApi` - Get tournament details
- **Teams API**: `/api/TeamsApi` - Manage teams
- **Matches API**: `/api/MatchesApi` - Update match scores
- **YouTube API**: `/api/YouTube` - Add match videos
