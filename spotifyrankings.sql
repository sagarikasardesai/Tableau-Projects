-- Visualization (Tableau) - https://public.tableau.com/app/profile/sagarikasardesai/viz/SpotifyRankings/Story1
-- top 10 track genres
select track_genre, coalesce(round(avg(popularity::decimal),2),0) as avg_pop,
       coalesce(round(avg(duration_ms::decimal),2),0) as avg_duration,
       coalesce(round(avg(danceability),2),0) as avg_danceability,
       coalesce(round(avg(energy),2),0) as avg_energy,
       coalesce(round(avg(loudness),2),0) as avg_loudness,
       coalesce(round(avg(speechiness),2),0) as avg_speechiness,
       coalesce(round(avg(acousticness),2),0) as avg_acousticness,
       coalesce(round(avg(instrumentalness),2),0) as avg_instrumentalness,
       coalesce(round(avg(liveness),2),0) as avg_liveness,
       coalesce(round(avg(valence),2),0) as avg_valence,
       coalesce(round(avg(tempo),2),0) as avg_tempo
from tracks.dataset group by 1 order by 2 desc limit 10;

--create view
create view topgenres as
    (select track_genre, coalesce(round(avg(popularity::decimal),2),0) as avg_pop,
       coalesce(round(avg(duration_ms::decimal),2),0) as avg_duration,
       coalesce(round(avg(danceability),2),0) as avg_danceability,
       coalesce(round(avg(energy),2),0) as avg_energy,
       coalesce(round(avg(loudness),2),0) as avg_loudness,
       coalesce(round(avg(speechiness),2),0) as avg_speechiness,
       coalesce(round(avg(acousticness),2),0) as avg_acousticness,
       coalesce(round(avg(instrumentalness),2),0) as avg_instrumentalness,
       coalesce(round(avg(liveness),2),0) as avg_liveness,
       coalesce(round(avg(valence),2),0) as avg_valence,
       coalesce(round(avg(tempo),2),0) as avg_tempo
     from tracks.dataset group by 1 order by 2 desc limit 10)

--top 10 songs in those top 10 genres
select * from (
    select tracks.dataset.track_genre as genre, tracks.dataset.artists as artists,
           tracks.dataset.popularity as popularity, tracks.dataset.track_name as track_name,
           row_number() over (partition by tracks.dataset.track_genre order by tracks.dataset.popularity desc) as seqnum
    from tracks.dataset join topgenres on topgenres.track_genre=tracks.dataset.track_genre
    group by 1,2,3,4 order by 1 asc) t
where seqnum <=10;

--top 10 albums or singles in those top 10 genres
select * from (
    select albums.genre as genre, albums.artists as artists, albums.album as album,
           albums.avg_popularity as avg_popularity,
           row_number() over (partition by albums.genre order by albums.avg_popularity desc) as seqnum
    from (select tracks.dataset.album_name                             as album,
                 tracks.dataset.track_genre                            as genre,
                 tracks.dataset.artists                                as artists,
                 coalesce(round(avg(tracks.dataset.popularity), 2), 0) as avg_popularity
          from tracks.dataset group by 1,2,3) albums join topgenres on topgenres.track_genre = albums.genre
    group by 1,3,2,4 order by 4 asc) t
where seqnum <=10;

--top 10 artist(s) in those top 10 genres
select * from (
    select a.genre as genre, a.artists as artists,
           a.avg_popularity as popularity,
           row_number() over (partition by a.genre order by a.avg_popularity desc) as seqnum
    from (select tracks.dataset.track_genre                            as genre,
                 tracks.dataset.artists                                as artists,
                 tracks.dataset.track_name                             as track,
                 coalesce(round(avg(tracks.dataset.popularity),2),0) as avg_popularity
          from tracks.dataset group by 2,1,3) a join topgenres on topgenres.track_genre = a.genre
    group by 1,2,3 order by 3 asc) t
where seqnum <=10;

select * from tracks.dataset limit 5;

