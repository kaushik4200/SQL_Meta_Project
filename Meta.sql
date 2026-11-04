OBJECTIVE QUESTIONS 

-- Ans 1.1 :
SELECT id, COUNT(*) AS cnt
FROM users
GROUP BY id
HAVING COUNT(*) > 1;

-- Ans 1.2 :
SELECT
SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS null_photo_id,
SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
SUM(CASE WHEN image_url IS NULL THEN 1 ELSE 0 END) AS null_image_url,
SUM(CASE WHEN created_dat IS NULL THEN 1 ELSE 0 END) AS null_created_at
FROM photos;

-- Ans 2 :
SELECT u.username,
COUNT(DISTINCT p.id) AS total_posts,
COUNT(DISTINCT l.photo_id) AS total_likes_given,
COUNT(DISTINCT c.id) AS total_comments_given
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username
ORDER BY total_posts DESC;

-- Ans 3 :
SELECT ROUND(AVG(tag_count),2) AS Average_Tags_Per_Post
FROM
( SELECT photo_id,
COUNT(tag_id) AS tag_count
FROM photo_tags
GROUP BY photo_id
) AS tags_per_photo;

-- Ans 4 :
SELECT u.username,
COUNT(DISTINCT l.user_id, l.photo_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
COUNT(DISTINCT l.user_id, l.photo_id) + COUNT(DISTINCT c.id) AS Total_Engagement
FROM users u
JOIN photos p
ON u.id = p.user_id
LEFT JOIN likes l
ON p.id = l.photo_id
LEFT JOIN comments c
ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY Total_Engagement DESC;

-- Ans 5 :
SELECT u.username,
COALESCE(f1.followers,0) AS Followers,
COALESCE(f2.followings,0) AS Followings
FROM users u
LEFT JOIN
(
SELECT followee_id,
COUNT(*) AS followers
FROM follows
GROUP BY followee_id
) f1
ON u.id=f1.followee_id
LEFT JOIN
(
SELECT
follower_id,
COUNT(*) AS followings
FROM follows
GROUP BY follower_id
) f2
ON u.id=f2.follower_id
ORDER BY followers DESC, followings DESC;

-- Ans 6 :
SELECT u.username,
COUNT(DISTINCT p.id) AS Total_Posts,
COUNT(DISTINCT l.user_id, l.photo_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
ROUND(
(
COUNT(DISTINCT l.user_id, l.photo_id) +
COUNT(DISTINCT c.id)) / COUNT(DISTINCT p.id),2
)
AS Avg_Engagement_Per_Post
FROM users u
JOIN photos p
ON u.id=p.user_id
LEFT JOIN likes l
ON p.id=l.photo_id
LEFT JOIN comments c
ON p.id=c.photo_id
GROUP BY u.id,u.username
ORDER BY Avg_Engagement_Per_Post DESC;

-- Ans 7 :
SELECT u.id,u.username
FROM users u
LEFT JOIN likes l
ON u.id = l.user_id
WHERE l.user_id IS NULL;

-- Ans 8 :
SELECT t.tag_name,
COUNT(DISTINCT pt.photo_id) AS Total_Posts,
COUNT(DISTINCT l.user_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
(COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS Total_Engagement
FROM tags t
JOIN photo_tags pt
ON t.id = pt.tag_id
LEFT JOIN likes l
ON pt.photo_id = l.photo_id
LEFT JOIN comments c
ON pt.photo_id = c.photo_id
GROUP BY t.id, t.tag_name
ORDER BY Total_Engagement DESC
LIMIT 10;

-- Ans 9 :
SELECT u.username,
    COUNT(DISTINCT p.id) AS Total_Posts,
COUNT(DISTINCT l.user_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
ROUND(
(COUNT(DISTINCT l.user_id) +
COUNT(DISTINCT c.id))/ COUNT(DISTINCT p.id),2) AS Avg_Engagement
FROM users u
JOIN photos p
ON u.id = p.user_id
LEFT JOIN likes l
ON p.id = l.photo_id
LEFT JOIN comments c
ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY Avg_Engagement DESC;

-- Ans 10 :
SELECT u.username,
COUNT(DISTINCT l.user_id, l.photo_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
COUNT(DISTINCT pt.photo_id, pt.tag_id) AS Total_Photo_Tags
FROM users u
JOIN photos p
ON u.id = p.user_id
LEFT JOIN likes l
ON p.id = l.photo_id
LEFT JOIN comments c
ON p.id = c.photo_id
LEFT JOIN photo_tags pt
ON p.id = pt.photo_id
GROUP BY u.id, u.username
ORDER BY Total_Likes DESC;

-- Ans 11 :
SELECT u.username,
COUNT(DISTINCT l.user_id, l.photo_id) AS Total_Likes,
COUNT(DISTINCT c.id) AS Total_Comments,
( COUNT(DISTINCT l.user_id, l.photo_id) + COUNT(DISTINCT c.id)
) AS Total_Engagement,
DENSE_RANK() OVER (
ORDER BY (
COUNT(DISTINCT l.user_id, l.photo_id) +
COUNT(DISTINCT c.id)
) DESC
) AS User_Rank
FROM users u
JOIN photos p
ON u.id = p.user_id
LEFT JOIN likes l
ON p.id = l.photo_id
AND MONTH(l.created_at) = 6
AND YEAR(l.created_at) = 2026
LEFT JOIN comments c
ON p.id = c.photo_id
AND MONTH(c.created_at) = 6
AND YEAR(c.created_at) = 2026
GROUP BY u.id, u.username
ORDER BY User_Rank;

-- Ans 12 :
WITH PhotoLikes AS (
SELECT p.id AS photo_id,
COUNT(l.user_id) AS total_likes
FROM photos p
LEFT JOIN likes l
ON p.id = l.photo_id
GROUP BY p.id
),
HashtagAvgLikes AS (
SELECT t.tag_name,
AVG(pl.total_likes) AS Avg_Likes
FROM tags t
JOIN photo_tags pt
ON t.id = pt.tag_id
JOIN PhotoLikes pl
ON pt.photo_id = pl.photo_id
GROUP BY t.id, t.tag_name
)
SELECT tag_name,
ROUND(Avg_Likes, 2) AS Average_Likes
FROM HashtagAvgLikes
ORDER BY Average_Likes DESC;

-- Ans 13 :
SELECT
f1.follower_id,
f1.followee_id
FROM follows f1
WHERE EXISTS (
SELECT 1
FROM follows f2
WHERE f1.follower_id = f2.followee_id
AND f1.followee_id = f2.follower_id
);