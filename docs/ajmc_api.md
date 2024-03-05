Using the Ajax Multi-Commentary API
------

## Example queries

### List all of the glosses on a given set of lines

```
GET /api/glosses?start={start}&end={end}&search={search}
```

`start` and `end` **must** be integers. `search` will be treated as a string.

You can optionally omit these querystring parameters to return _all_ glosses.

### List all available commentaries

```
GET /api/commentaries
```

### List all available public commentaries

```
GET /api/commentaries?public=true
```

### Show a specific commentary

```
GET /api/commentaries/{commentary_urn}
```

`commentary_urn` must match one of the known commentaries, e.g., `urn:cts:greekLit:tlg0011.tlg003.ajmc-jeb` for Jebb's commentary.

### List glosses for a given commentary

```
GET /api/commentaries/{commentary_urn}/glosses
```

### List lemmata for a given commentary

```
GET /api/commentaries/{commentary_urn}/lemmas
```