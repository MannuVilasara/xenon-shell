import QtQuick
import Quickshell
pragma Singleton

Item {
    id: root

    property string temperature: "--"
    property string conditionText: "Unknown"
    property string city: "Locating..."
    property string icon: ""
    property bool isDay: true
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string pressure: "-- hPa"
    property string uvIndex: "--"
    property string sunrise: "--:--"
    property string sunset: "--:--"
    property var hourlyForecast: []
    property var forecastModel: []
    property int refreshInterval: 1.8e+06

    // New properties for visual effects
    property int weatherCode: 0
    property real currentHour: 12.0
    property string rawSunrise: ""
    property string rawSunset: ""

    property real visualSunriseHour: 6.0
    property real visualSunsetHour: 18.0

    function parseTime(timeStr) {
        if (!timeStr) return 0;
        var parts = timeStr.split(":");
        // Handle "10:30 PM" or "10:30" formats gently if needed, but API usually returns ISO or 24h
        // The API actually returns "2023-01-01T06:30" so we need to split by T and then :
        if (timeStr.indexOf("T") !== -1) {
             timeStr = timeStr.split("T")[1];
        }
        parts = timeStr.split(":");
        return parseInt(parts[0]) + parseInt(parts[1]) / 60;
    }

    readonly property real realSunriseHour: rawSunrise.length > 0 ? parseTime(rawSunrise) : 6.0
    readonly property real realSunsetHour: rawSunset.length > 0 ? parseTime(rawSunset) : 18.0

    function calculateSunProgress(hour, sunriseH, sunsetH) {
        if (hour >= sunriseH && hour <= sunsetH) {
            return (hour - sunriseH) / (sunsetH - sunriseH);
        } else {
            var nightDuration = 24 - (sunsetH - sunriseH);
            if (hour > sunsetH) {
                return (hour - sunsetH) / nightDuration;
            } else {
                return (hour + (24 - sunsetH)) / nightDuration;
            }
        }
    }

    function calculateTimeBlend(hour) {
        var day = 0, evening = 0, night = 0;
        if (hour >= 9 && hour <= 17) {
            day = 1.0;
        } else if (hour > 8 && hour < 9) {
            var t = hour - 8;
            evening = 1.0 - t;
            day = t;
        } else if (hour > 17 && hour < 18) {
            var t = hour - 17;
            day = 1.0 - t;
            evening = t;
        } else if (hour >= 6 && hour <= 8) {
            evening = 1.0;
        } else if (hour >= 18 && hour <= 20) {
            evening = 1.0;
        } else if (hour > 5 && hour < 6) {
            var t = hour - 5;
            night = 1.0 - t;
            evening = t;
        } else if (hour > 20 && hour < 21) {
            var t = hour - 20;
            evening = 1.0 - t;
            night = t;
        } else {
            night = 1.0;
        }
        return { day: day, evening: evening, night: night };
    }

    readonly property var effectiveTimeBlend: calculateTimeBlend(currentHour)
    readonly property real effectiveSunProgress: calculateSunProgress(currentHour, visualSunriseHour, visualSunsetHour)
    
    // Determine if it is effectively day based on the visual/real sunrise logic
    readonly property bool effectiveIsDay: currentHour >= realSunriseHour && currentHour <= realSunsetHour

    function getWeatherEffect(code) {
        if (code === 0 || code === 1) return "clear";
        if (code === 2 || code === 3) return "clouds";
        if (code === 45 || code === 48) return "fog";
        if (code >= 51 && code <= 57) return "drizzle";
        if (code >= 61 && code <= 67) return "rain";
        if (code >= 71 && code <= 77) return "snow";
        if (code >= 80 && code <= 82) return "rain";
        if (code >= 85 && code <= 86) return "snow";
        if (code === 95) return "thunderstorm";
        if (code >= 96 && code <= 99) return "thunderstorm";
        return "clear";
    }

    function getWeatherIntensity(code) {
        if (code === 0 || code === 1) return 0.0;
        if (code === 2) return 0.5;
        if (code === 3) return 1.0;
        if (code === 45) return 0.5;
        if (code === 48) return 0.7;
        if (code === 51 || code === 56) return 0.3;
        if (code === 53) return 0.5;
        if (code === 55 || code === 57) return 0.7;
        if (code === 61) return 0.4;
        if (code === 63 || code === 66) return 0.6;
        if (code === 65 || code === 67) return 0.9;
        if (code === 71) return 0.3;
        if (code === 73) return 0.5;
        if (code === 75 || code === 77) return 0.8;
        if (code === 80) return 0.5;
        if (code === 81) return 0.7;
        if (code === 82) return 1.0;
        if (code === 85) return 0.6;
        if (code === 86) return 0.9;
        if (code === 95) return 0.8;
        if (code >= 96) return 1.0;
        return 0.0;
    }

    readonly property string effectiveWeatherEffect: getWeatherEffect(weatherCode)
    readonly property real effectiveWeatherIntensity: getWeatherIntensity(weatherCode)

    Timer {
        interval: 60000 // 1 minute
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            root.currentHour = now.getHours() + now.getMinutes() / 60.0;
        }
    }

    property var _weatherCodes: {
        "0": {
            "day": "󰖙", // mdi-weather-sunny
            "night": "󰖔", // mdi-weather-night
            "desc": "Clear sky"
        },
        "1": {
            "day": "󰖙",
            "night": "󰖔",
            "desc": "Mainly clear"
        },
        "2": {
            "day": "󰖐", // mdi-weather-partly-cloudy
            "night": "󰖔", // mdi-weather-night-partly-cloudy
            "desc": "Partly cloudy"
        },
        "3": {
            "day": "󰖐",
            "night": "󰖐",
            "desc": "Overcast"
        },
        "45": {
            "day": "󰖑", // mdi-weather-fog
            "night": "󰖑",
            "desc": "Fog"
        },
        "48": {
            "day": "󰖑",
            "night": "󰖑",
            "desc": "Depositing rime fog"
        },
        "51": {
            "day": "󰖗", // mdi-weather-rain
            "night": "󰖗",
            "desc": "Light drizzle"
        },
        "53": {
            "day": "󰖗",
            "night": "󰖗",
            "desc": "Moderate drizzle"
        },
        "55": {
            "day": "󰖗",
            "night": "󰖗",
            "desc": "Dense drizzle"
        },
        "61": {
            "day": "󰖖", // mdi-weather-pouring
            "night": "󰖖",
            "desc": "Slight rain"
        },
        "63": {
            "day": "󰖖",
            "night": "󰖖",
            "desc": "Moderate rain"
        },
        "65": {
            "day": "󰖖",
            "night": "󰖖",
            "desc": "Heavy rain"
        },
        "71": {
            "day": "󰖘", // mdi-weather-snow
            "night": "󰖘",
            "desc": "Slight snow"
        },
        "73": {
            "day": "󰖘",
            "night": "󰖘",
            "desc": "Moderate snow"
        },
        "75": {
            "day": "󰖘",
            "night": "󰖘",
            "desc": "Heavy snow"
        },
        "77": {
            "day": "󰖘",
            "night": "󰖘",
            "desc": "Snow grains"
        },
        "80": {
            "day": "󰖖",
            "night": "󰖖",
            "desc": "Slight rain showers"
        },
        "81": {
            "day": "󰖖",
            "night": "󰖖",
            "desc": "Moderate rain showers"
        },
        "82": {
            "day": "󰖖",
            "night": "󰖖",
            "desc": "Violent rain showers"
        },
        "85": {
            "day": "󰖘",
            "night": "󰖘",
            "desc": "Slight snow showers"
        },
        "86": {
            "day": "󰖘",
            "night": "󰖘",
            "desc": "Heavy snow showers"
        },
        "95": {
            "day": "󰖓", // mdi-weather-lightning
            "night": "󰖓",
            "desc": "Thunderstorm"
        },
        "96": {
            "day": "󰖓",
            "night": "󰖓",
            "desc": "Thunderstorm with hail"
        },
        "99": {
            "day": "󰖓",
            "night": "󰖓",
            "desc": "Thunderstorm with heavy hail"
        }
    }

    function formatTime(isoString) {
        if (!isoString)
            return "--:--";

        var date = new Date(isoString);
        return date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat).replace(/:\d\d /, " ");
    }

    function getDayName(dateString) {
        // manually parse "YYYY-MM-DD" to avoid UTC/Timezone shifts
        var parts = dateString.split("-");
        var year = parseInt(parts[0]);
        var month = parseInt(parts[1]) - 1; // months are 0-indexed
        var day = parseInt(parts[2]);
        var date = new Date(year, month, day);
        return date.toLocaleDateString(Qt.locale(), "ddd");
    }

    function fetchLocation() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.city)
                            root.city = response.city;

                        fetchWeather(response.lat, response.lon);
                    } catch (e) {
                        console.warn("[Weather] Location JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", "http://ip-api.com/json");
        xhr.send();
    }

    function fetchWeather(lat, lon) {
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,is_day,weather_code,relative_humidity_2m,wind_speed_10m,surface_pressure" + "&hourly=temperature_2m" + "&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset" + "&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=7";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var current = response.current;
                        root.temperature = Math.round(current.temperature_2m) + "°";
                        root.isDay = current.is_day === 1;
                        root.humidity = current.relative_humidity_2m + "%";
                        root.wind = current.wind_speed_10m + " km/h";
                        root.pressure = Math.round(current.surface_pressure) + " hPa";
                        root.weatherCode = current.weather_code;
                        var code = current.weather_code;
                        var info = root._weatherCodes[code] || {
                            "day": "",
                            "night": "",
                            "desc": "Unknown"
                        };
                        root.icon = root.isDay ? info.day : info.night;
                        root.conditionText = info.desc;
                        var daily = response.daily;
                        if (daily) {
                            if (daily.uv_index_max && daily.uv_index_max.length > 0)
                                root.uvIndex = daily.uv_index_max[0].toString();

                            if (daily.sunrise && daily.sunrise.length > 0) {
                                root.sunrise = formatTime(daily.sunrise[0]);
                                root.rawSunrise = daily.sunrise[0];
                            }

                            if (daily.sunset && daily.sunset.length > 0) {
                                root.sunset = formatTime(daily.sunset[0]);
                                root.rawSunset = daily.sunset[0];
                            }

                        }
                        var hourly = response.hourly;
                        if (hourly && hourly.temperature_2m) {
                            var currentHourIndex = new Date().getHours();
                            var slice = hourly.temperature_2m.slice(currentHourIndex, currentHourIndex + 24);
                            root.hourlyForecast = slice;
                        }
                        var newForecast = [];
                        for (var i = 0; i < 5; i++) {
                            if (!daily.time[i])
                                break;

                            var fCode = daily.weather_code[i];
                            var fInfo = root._weatherCodes[fCode] || {
                                "day": "",
                                "desc": "Unknown"
                            };
                            newForecast.push({
                                "day": getDayName(daily.time[i]),
                                "icon": fInfo.day,
                                "max": Math.round(daily.temperature_2m_max[i]) + "°",
                                "min": Math.round(daily.temperature_2m_min[i]) + "°",
                                "condition": fInfo.desc
                            });
                        }
                        root.forecastModel = newForecast;
                    } catch (e) {
                        console.warn("[Weather] Weather JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchLocation()
    }

}
