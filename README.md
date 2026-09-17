# Bookshelf

Bookshelf is a Flutter application that allows users to search for books using the Open Library API, view book details, save books as favourites, and access cached search results while offline.


---

## Features

### Book Search

Users can search for books using the Open Library API.

The search feature includes:

- Debounced search input
- Paginated results
- Loading state
- Empty state
- Error state
- Book cover
- Title
- Author
- First publication year

Search endpoint:

```text
GET https://openlibrary.org/search.json?q=<term>&page=<page>
```

---

### Book Details

Selecting a search result opens a detail screen.

The detail screen displays:

- Cover
- Title
- Authors
- First publication year
- Description
- Subjects

Book detail endpoint:

```text
GET https://openlibrary.org/works/<work_id>.json
```

The application handles different Open Library description formats, including:

- Plain string descriptions
- Description objects containing a `value`
- Missing descriptions

---

### Favourites

Books can be added to or removed from favourites from both:

- Search results
- Book detail screen

Favourites are stored locally using SQLite and remain available after the application is restarted.

A dedicated Favourites screen allows users to:

- View saved books
- Open book details
- Remove books from favourites

Favourite state is shared across the application, so a change made on one screen is reflected on the other screens.

---

### Offline Search

Successful first-page search results are cached locally using SQLite.

If a search request fails, the application attempts to load cached results for the same query.

When cached results are displayed, the UI shows:

```text
Offline — showing cached search results
```

Only the initial search results are cached. Paginated pages are not currently cached.

Favourites remain readable offline because they are stored locally.

---

## Architecture

The project follows a feature-first layered architecture.

```text
lib/
├── app/
│   ├── app_dependencies.dart
│   ├── bookshelf_app.dart
│   └── router/
│
├── database/
│   └── app_database.dart
│
├── network/
│   ├── app_http_client.dart
│   └── http_client.dart
│
├── search/
│   ├── models/
│   ├── repository/
│   ├── services/
│   ├── view_models/
│   └── views/
│
├── book_details/
│   ├── repository/
│   ├── services/
│   ├── view_models/
│   └── views/
│
└── favourites/
    ├── models/
    ├── providers/
    ├── repository/
    ├── services/
    └── views/
```

The main application flow is:

```text
UI
↓
ViewModel / Provider
↓
Repository
↓
Data Source
↓
HTTP or SQLite
```

### Presentation Layer

The presentation layer contains the Flutter screens and application state.

Examples include:

```text
SearchPage
BookDetailPage
FavouritesPage

SearchViewModel
BookDetailViewModel
FavouritesProvider
```

Widgets are responsible for displaying state and handling user interaction. API and database operations are not performed directly inside the UI.

### Repository Layer

Repositories sit between the presentation layer and the data sources.

The project contains:

```text
SearchRepository
BookDetailRepository
FavouritesRepository
```

The repository layer makes it easier for the presentation layer to work with data without needing to know whether the data comes from an API or SQLite.

The `SearchRepository` also coordinates remote search data and cached search data.

### Data Layer

The data layer is responsible for getting and storing data.

Examples include:

```text
OpenLibraryRemoteDataSource
OpenLibraryBookDetailDataSource
SqliteSearchCacheDataSource
SqliteFavouritesLocalDataSource
```

Data sources sit behind interfaces so that they can be mocked or replaced during testing.

---

## Dependency Injection

Dependencies are created centrally inside:

```text
lib/app/app_dependencies.dart
```

The application UI does not create repositories, HTTP clients, or database services directly.

For example:

```text
AppDependencies
↓
SearchRepository
├── OpenLibraryRemoteDataSource
└── SqliteSearchCacheDataSource
```

This keeps object creation in one place and makes the application easier to test and maintain.

---

## State Management

The application uses `Provider` with `ChangeNotifier`.

The main state objects are:

```text
SearchViewModel
BookDetailViewModel
FavouritesProvider
```

Provider was chosen because the state requirements for this project are relatively small and straightforward.

It provides:

- Reactive UI updates
- Dependency access through the widget tree
- Separation between UI and application logic
- Straightforward unit and widget testing

For a much larger application with more complex state transitions, Riverpod or BLoC could also be considered.

---

## Search State

Search uses explicit states:

```text
SearchInitial
SearchLoading
SearchResults
SearchEmpty
SearchError
```

`SearchResults` also contains:

```text
isLoadingMore
isOffline
```

This allows the UI to distinguish between:

- Normal search results
- Pagination loading
- Cached offline results

---

## Defensive Mapping

The Open Library API does not always return every field.

The application handles cases such as:

- Missing `author_name`
- Missing `cover_i`
- Missing `first_publish_year`
- Description returned as a string
- Description returned as an object
- Missing description
- Missing subjects

UI fallback values include:

```text
Unknown author
Year unknown
No description available.
```

Books without covers display a placeholder book icon.

---

## Local Storage

SQLite is used for persistent local storage.

The application database contains:

```text
favourites
search_cache
```

### Favourites Table

The favourites table stores:

```text
work_id
title
authors
first_publish_year
cover_id
```

This allows favourites to remain readable without an internet connection.

### Search Cache Table

The search cache stores:

```text
query
work_id
title
authors
first_publish_year
cover_id
position
```

The `position` field is used to preserve the order in which results were returned by the API.

---

## Testing

Testing was treated as an important part of the project.

The project includes:

- Model mapping tests
- Repository tests
- ViewModel tests
- SQLite persistence tests
- Widget tests
- Offline fallback tests
- Favourite toggle tests
- Search state tests
- Book detail state tests

Repository tests use mocked HTTP dependencies.

SQLite tests use:

```text
sqflite_common_ffi
```

This allows SQLite tests to run without requiring a physical mobile device.

### Run Tests

```bash
flutter test
```

### Run Tests With Coverage

```bash
flutter test --coverage
```

The generated coverage report is stored at:

```text
coverage/lcov.info
```

Current line coverage:

```text
83.5%
```

The assessment target of at least 80% line coverage is therefore met.

---

## Static Analysis

Run:

```bash
flutter analyze
```

Current result:

```text
No issues found!
```

---

## Running the Application

### Requirements

You will need:

- Flutter SDK
- Dart SDK
- Android Studio, VS Code, or IntelliJ IDEA
- Android emulator, iOS simulator, or physical device

Clone the repository:

```bash
git clone https://github.com/itumelengseema/bookshelf.git
```

Move into the project:

```bash
cd bookshelf
```

Install dependencies:

```bash
flutter pub get
```

Generate AutoRoute files:

```bash
dart run build_runner build
```

Run the application:

```bash
flutter run
```

---

## Code Generation

AutoRoute is used for navigation.

Generated route files can be recreated with:

```bash
dart run build_runner build
```

Generated files should not be edited manually.

---

## Git Workflow

Development was completed using feature branches.

Examples include:

```text
feature/search
feature/book-detail
feature/favourites
feature/offline-cache
```

Changes were merged into `main` using pull requests.

Commits were kept focused around individual features, fixes, tests, and refactoring.

---

## AI Usage

AI tools were used as a development support tool during this assessment.

AI assistance was used for:

- Discussing architecture options
- Explaining Flutter concepts
- Reviewing implementation ideas
- Debugging errors
- Suggesting test cases
- Reviewing test failures
- Improving documentation
- Discussing dependency injection and state management

All suggested code was reviewed, adapted where necessary, tested, and integrated into the project.

I am able to explain the code, architecture, state management, testing approach, and implementation decisions used in this project.

---

## Limitations

The current implementation has the following limitations:

- Only the first page of search results is cached for offline use.
- Paginated search pages are not cached.
- Book detail API responses are not cached.
- When offline, cached search results can still be viewed, but opening book details may fail because the detail endpoint still requires a network connection.
- Search caching is based on the search query.
- There is no user authentication.
- UI styling is intentionally simple because the focus of the assessment is architecture, testing, maintainability, and functionality.

---

## Possible Future Improvements

Possible future improvements include:

- Cache book detail responses
- Cache paginated search results
- Add retry controls for failed requests
- Add improved image caching
- Add dark mode
- Add GitHub Actions for automatic analysis and testing
- Add more detailed loading and error feedback

---

## Time Spent

Approximately 14 hours over 4 days, starting Monday afternoon.

The majority of the time was spent on:

- Project architecture and dependency injection
- Search and pagination
- Defensive API mapping
- Repository and widget testing
- SQLite favourites persistence
- Offline search caching
- Debugging and refactoring
- Test coverage and documentation


## Screenshots

### Search
![Search](screenshots/search.png)

### Book Details
![Book Details](screenshots/book-detail.png)

### Favourites
![Favourites](screenshots/favourites.png)

### Offline Search
![Offline Search](screenshots/offline-search.png)
## Author

Itumeleng Seema
