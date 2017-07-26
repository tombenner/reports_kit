### Measures

The measure is what is being counted (or aggregated in another way). You can use any model as the measure.

For example, say we have a `Flight` model with a `flight_at` datetime column. We can chart the number of flights over time:

```yaml
measure: flight
dimensions:
- flight_at
```
[<img src="images/flights_by_flight_at.png?raw=true" width="500" />](images/flights_by_flight_at.png?raw=true)
