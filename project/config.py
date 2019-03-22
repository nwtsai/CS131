KEY = "AIzaSyCwjlHvQxcsD0IqtEiOXbb0cviOi-88WGo"

serverIDs = {
	"Goloman": 11670,
	"Hands": 11671,
	"Holiday": 11672,
	"Welsh": 11673,
	"Wilkes": 11674
}

herd_links = {
	"Goloman": ["Hands", "Holiday", "Wilkes"],
	"Hands": ["Goloman", "Wilkes"],
	"Holiday": ["Goloman", "Welsh", "Wilkes"],
	"Welsh": ["Holiday"],
	"Wilkes": ["Goloman", "Hands", "Holiday"]
}
