# Bucket Collect Ball Game

**Name:** Yuvraj Chiragbhai Patel  
**Student ID:** 1224030

## Overview

This project is a game of catching ball using bucket using Lua and Corona SDK/Solar 2D framework. The game features a scoring system, lives mechanism, progressive difficulty, and persistent high scoring tracking. This game offers 3 lives for the ball to be missed after that the game stops and offers to restart.

## Project Structure

The main functions and variables are in the main file and assets used are in their original form and are in the same directory.

## Features

- Physics-based gameplay with realistic ball dropping mechanics
- Touch controls to move bucket horizontally
- Scoring system with bonus speed increases every 10 points
- Lives system (3 lives) – lose a life when a is missed.
- Persistent high score saved to local storage using JSON
- Pause/Resume functionality with on-screen pause button
- Progressive difficulty – ball spawn rate increases as score increases by multiple of 10 points
- Visual feedback with bonus text animations and score shadows

## Installation Instructions

**Github Link:** https://github.com/YuvrajPatel23/Ball_catching_game

### Prerequisites

1. Corona SDK/Solar2D - download and install
2. Corona simulator

### Setup Steps

1. **Clone repository**

   ```bash
   git clone https://github.com/YuvrajPatel23/Ball_catching_game
   cd Ball_catching_game
   ```

2. **Verify assets**

   - Main.lua
   - Background.jpg
   - Bucket.png

3. **Create Configuration files**

4. **Launch Game**
   - Open Corona Simulator
   - Select "Open Project" and choose the main.lua
   - The game will launch automatically

## Output Screenshots

### Main Game Screen

![Main Game Screen](/Output/Picture1.png)
_Screenshot showing the main gameplay with falling balls, bucket, score display, and UI elements_

### Game Over Screen

![Game Over Screen](/Output/Picture2.png)
_Screenshot showing the game over state with final score and restart option_

### Bonus Points

![Bonus Points](/Output/Picture3.png)
_Screenshot showing the bonus points animation when speed increases_
