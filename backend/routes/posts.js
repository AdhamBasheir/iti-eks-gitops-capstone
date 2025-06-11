var express = require('express');
var router = express.Router();
const Post = require('../models/post');
const redis = require('../db/redis');
const { client, register } = require('../metrics');

const totalRequests = new client.Counter({
  name: 'posts_api_requests_total',
  help: 'Total number of requests to /posts',
  labelNames: ['method', 'route'],
  registers: [register],
});

const successfulResponses = new client.Counter({
  name: 'posts_api_success_total',
  help: 'Total number of successful responses from /posts',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const failedResponses = new client.Counter({
  name: 'posts_api_failures_total',
  help: 'Total number of failed responses from /posts',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});


router.get('/', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/' });
  try {
      const posts = await Post.findAll();

      successfulResponses.inc({ method: req.method, route: '/', status: 200 });
      console.log('Returning posts from database');
      return res.status(200).json({ data: posts });
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/', status: 500 });
    console.error('Error retrieving posts:', error);
    res.status(500).json({ error: 'Error retrieving posts' });
  }
});

router.post('/', async (req, res) => {
  const { title, description } = req.body;
  totalRequests.inc({ method: req.method, route: '/' });
  try {
    const newPost = await Post.create({ title, description });
    successfulResponses.inc({ method: req.method, route: '/', status: 200 });
    console.log('Post created successfully:', newPost);

    res.status(201).json(newPost);
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/', status: 500 });
    console.error('Error creating post:', error);
    res.status(400).json({ error: 'Error creating post' });
  }
});


router.get('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  try {
      const post = await Post.findByPk(id);
      if (post) {
        successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
        console.log('Returning post from database');
        return res.status(200).json(post);
      } else {
        failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
        console.log('Post not found');
        return res.status(404).json({ error: 'Post not found' });
      }
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error retrieving post:', error);
    res.status(500).json({ error: 'Error retrieving post' });
  }
});

router.put('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  const { title, description } = req.body;
  try {
    const post = await Post.findByPk(id);
    if (post) {

      post.title = title || post.title;
      post.description = description || post.description;
      await post.save();
      successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
      console.log('Post updated successfully:', post);


      res.status(200).json(post);
    } else {
      failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
      console.log('Post not found');
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error updating post:', error);
    res.status(500).json({ error: 'Error updating post' });
  }
});

router.delete('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      await post.destroy();
      successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
      console.log('Post deleted successfully:', post);

      res.status(200).json({ message: 'Post deleted successfully' });
    } else {
      failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
      console.log('Post not found');
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    console.error('Error deleting post:', error);
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Error deleting post' });
  }
});

module.exports = router;
