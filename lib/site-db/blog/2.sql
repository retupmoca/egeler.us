ALTER TABLE `posts` DROP COLUMN `tags`;

CREATE TABLE `post_tags` {
  `post_id` int(11) NOT NULL,
  `tag` varchar(50) NOT NULL
} ENGINE=InnoDB DEFAULT CHARSET=utf8;
