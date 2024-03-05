Using the Ajax Multi-Commentary API
------

## Example queries

### List all of the glosses on a given set of lines

```
GET /api/glosses?start={start}&end={end}&search={search}
```

`start` and `end` **must** be integers. `search` will be treated as a string.

You can optionally omit these querystring parameters to return _all_ glosses.

Supported querystring parameters:

- `commentary_urn`: The URN of the commentary for which to restrict the request.
- `lemma`: The lemma of the gloss for which to restrict the request.
- `start`: The starting line (inclusive) for which to restrict the request
- `end`: The ending line (inclusive) for which to restrict the request
- `search`: A string to search for within the glosses, as restricted by the other querystring parameters.

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

Supported querystring parameters:

- `lemma`: The lemma of the gloss for which to restrict the request.
- `start`: The starting line (inclusive) for which to restrict the request
- `end`: The ending line (inclusive) for which to restrict the request
- `search`: A string to search for within the _glosses_, as restricted by the other querystring parameters.

### List lemmata for a given commentary

```
GET /api/commentaries/{commentary_urn}/lemmas
```

Supported querystring parameters:

- `start`: The starting line (inclusive) for which to restrict the request
- `end`: The ending line (inclusive) for which to restrict the request
- `search`: A string to search for within the _glosses_, as restricted by the other querystring parameters.