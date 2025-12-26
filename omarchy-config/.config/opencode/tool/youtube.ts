import { tool } from "@opencode-ai/plugin"

const SCRIPTS_DIR = process.env.YT_SCRAPE_DIR || `${process.env.HOME}/s/yt-scrape/scripts`

export const info = tool({
  description: `Get YouTube video metadata without downloading.
Returns: title, description, duration, channel, chapters, available subtitle languages.
Use FIRST to check what's available. Fast, no API calls.
ESCALATION: If you need actual content, try youtube_transcript next.`,
  args: {
    url: tool.schema.string().describe("YouTube video URL (youtube.com/watch?v= or youtu.be/)"),
  },
  async execute({ url }) {
    try {
      const result = await Bun.$`${SCRIPTS_DIR}/youtube-info.sh ${url}`.text()
      return result
    } catch (e: any) {
      return JSON.stringify({ success: false, error: e.message })
    }
  },
})

export const transcript = tool({
  description: `Extract YouTube transcript using subtitles (fast, no API calls).
Uses yt-dlp to download auto-generated or manual subtitles.
Format 'clean' removes timestamps for LLM consumption.
ESCALATION: If no subtitles or need speaker identification, use youtube_analyze.`,
  args: {
    url: tool.schema.string().describe("YouTube video URL"),
    language: tool.schema.string().default("en").describe("Subtitle language code (e.g., 'en', 'es', 'ja')"),
    format: tool.schema.enum(["clean", "srt"]).default("clean")
      .describe("'clean' = text only, 'srt' = with timestamps"),
    includeMetadata: tool.schema.boolean().default(true)
      .describe("Include video title and channel"),
  },
  async execute({ url, language, format, includeMetadata }) {
    try {
      const result = await Bun.$`${SCRIPTS_DIR}/youtube-transcript.sh ${url} ${language} ${format} ${includeMetadata}`.text()
      return result
    } catch (e: any) {
      return JSON.stringify({ 
        success: false, 
        error: e.message,
        escalation: "Try youtube_analyze for AI-powered transcription"
      })
    }
  },
})

export const analyze = tool({
  description: `Analyze YouTube video using Gemini AI.
Gemini processes the YouTube URL directly (no download needed).
Supports speaker diarization, emotion detection, timestamps.
Uses API quota. ESCALATION: If rate limited, use youtube_audio.`,
  args: {
    url: tool.schema.string().describe("YouTube video URL"),
    prompt: tool.schema.string().optional()
      .describe("Custom analysis prompt. Default: transcript with speaker IDs and timestamps"),
    identifySpeakers: tool.schema.boolean().default(true)
      .describe("Include speaker identification ([Speaker 1], [Speaker 2], etc)"),
  },
  async execute({ url, prompt, identifySpeakers }) {
    try {
      const result = await Bun.$`${SCRIPTS_DIR}/youtube-analyze.sh ${url} ${prompt || ""} ${String(identifySpeakers)}`.text()
      return result
    } catch (e: any) {
      return JSON.stringify({ 
        success: false, 
        error: e.message,
        escalation: "Try youtube_audio for audio download + transcription"
      })
    }
  },
})

export const audio = tool({
  description: `Download YouTube audio and transcribe via Gemini Files API.
Most reliable method - works when others fail.
Downloads audio, uploads to Gemini, transcribes.
Slowest but highest quality. Use as last resort.`,
  args: {
    url: tool.schema.string().describe("YouTube video URL"),
    prompt: tool.schema.string().optional()
      .describe("Custom transcription prompt"),
    keepAudio: tool.schema.boolean().default(false)
      .describe("Keep downloaded audio file after transcription"),
    outputDir: tool.schema.string().default("/tmp")
      .describe("Directory to save audio if keepAudio=true"),
  },
  async execute({ url, prompt, keepAudio, outputDir }) {
    try {
      const result = await Bun.$`${SCRIPTS_DIR}/youtube-audio.sh ${url} ${prompt || ""} ${String(keepAudio)} ${outputDir}`.text()
      return result
    } catch (e: any) {
      return JSON.stringify({ success: false, error: e.message })
    }
  },
})
