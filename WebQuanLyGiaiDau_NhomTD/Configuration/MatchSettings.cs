namespace WebQuanLyGiaiDau_NhomTD.Configuration
{
    /// <summary>
    /// Configuration settings for match durations and rules
    /// </summary>
    public class MatchSettings
    {
        /// <summary>
        /// Duration of 3v3 basketball match in minutes (default: 15)
        /// </summary>
        public int Match3v3DurationMinutes { get; set; } = 15;

        /// <summary>
        /// Duration of 5v5 basketball match in minutes (default: 69)
        /// NBA 5v5: 4 quarters x 12 minutes = 48 minutes of play time
        /// 3 x 2 minutes break between quarters = 6 minutes
        /// 1 x 15 minutes halftime break = 15 minutes
        /// Total: 48 + 6 + 15 = 69 minutes
        /// </summary>
        public int Match5v5DurationMinutes { get; set; } = 69;

        /// <summary>
        /// Attack time limit in seconds for 3v3 (default: 12)
        /// </summary>
        public int AttackTime3v3Seconds { get; set; } = 12;

        /// <summary>
        /// Attack time limit in seconds for 5v5 (default: 24)
        /// </summary>
        public int AttackTime5v5Seconds { get; set; } = 24;

        /// <summary>
        /// Winning score for 3v3 basketball (default: 21)
        /// </summary>
        public int WinningScore3v3 { get; set; } = 21;

        /// <summary>
        /// Minimum number of players per team for 3v3 (default: 3)
        /// </summary>
        public int MinPlayers3v3 { get; set; } = 3;

        /// <summary>
        /// Minimum number of players per team for 5v5 (default: 5)
        /// </summary>
        public int MinPlayers5v5 { get; set; } = 5;
    }
}
