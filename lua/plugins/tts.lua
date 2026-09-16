return {
  'chriswritescode-dev/tts.nvim',
  config = function()
    require('tts').setup({
      -- Backend selection: 'auto', 'macos', 'openai'
      -- 'openai' means the OpenAI-compatible HTTP API, which kokoro-fastapi
      -- serves locally. 'auto' probes the macOS `say` backend first and finds
      -- nothing on Linux.
      backend = 'openai',

      -- macOS configuration
      macos = {
        voice = 'Alex',
        rate = 200,              -- 75-720 words per minute
        volume = 0.5,            -- 0.0-1.0
        audio_device = nil,      -- Custom audio device
        pitch = nil,             -- Voice pitch
        modulation = nil,        -- Voice modulation
      },

      -- Local kokoro-fastapi, declared as an oci-container in modules/hardware.nix.
      -- tts.nvim skips the API key check for any api_url that is not
      -- api.openai.com, so no key is needed.
      openai = {
        api_key = nil,
        api_url = 'http://127.0.0.1:8880/v1/audio/speech',
        model = 'kokoro',
        voice = 'af_heart',      -- af_*/am_* are US voices, bf_*/bm_* are UK
        speed = 1.6,             -- 0.25-4.0; measured ~277 wpm on af_heart
                                 -- (1.0 is 174 wpm, 1.3 is 212)
        format = 'mp3',          -- mp3, opus, aac, flac
        headers = {},            -- Custom headers
        timeout = 30,            -- Request timeout in seconds
      },

      -- Playback behavior
      playback = {
        auto_clear_queue = false,
        show_progress = true,
        -- Break on sentence ends rather than a fixed line count. The splitter
        -- cuts on . ! or ? followed by whitespace, carrying closing quotes and
        -- brackets along with it.
        segmentation = 'sentence',           -- Split text into segments: 'line', 'sentence', or 'none'
        lines_per_segment = 2,               -- 'line' mode only, unused while segmentation is 'sentence'
        -- Only the first segment is ever waited on, since kokoro synthesizes at
        -- ~4x realtime and prefetch_next stays ahead after that. One sentence is
        -- under a second.
        chunk_size = 500,                    -- Max segment length before a segment is split further ('sentence' mode only)
        pause_between_chunks = 0,            -- Delay between segments on natural advance only (seconds)
        player = 'auto',                     -- Audio player: 'auto', 'mpv', 'ffplay', etc.
        player_args = {},                    -- Custom player arguments
        default_selection = 'buffer',       -- Default text selection: 'line', 'paragraph', 'section', 'buffer'
        follow = true,                       -- Move the cursor to the playing segment and highlight its lines
      },

      -- Cache settings
      cache = {
        enabled = true,
        directory = vim.fn.stdpath('cache') .. '/tts',
        max_size = 100,          -- MB
        max_age = 7,             -- days
        cleanup_on_start = true,
        prefetch_next = true,    -- Warm the next segment while the current one plays
      },

      -- Custom keymaps
      keymaps = {
        play = '<leader>tp',
        stop = '<leader>ts',
        queue = '<leader>tq',
        clear = '<leader>tc',
        next = '<leader>tn',
        prev = '<leader>tN',
        visual_play = '<leader>tp',
      },

      -- Text preprocessing
      preprocessing = {
        clean_markdown = true,           -- Remove markdown syntax
        clean_code = false,              -- Remove code comments
        filtering_level = 'moderate',    -- 'none', 'minimal', 'moderate', 'aggressive'
        expand_abbreviations = true,
        skip_code_blocks = true,         -- Skip code blocks entirely
        -- These keys go straight into text:gsub() as Lua patterns, so they need
        -- word boundaries. Bare 'AI' turned MAIL into "Martificial intelligenceL"
        -- and bare 'TS' turned STATS into "STATypeScript". %f[%w] and %f[%W] are
        -- the frontier pattern, Lua's nearest thing to \b.
        -- The dotted abbreviations are gone: expand_abbreviations above already
        -- handles e.g./i.e./etc. with the dots escaped. The copies here had bare
        -- dots, so 'i.e.' meant "i, anything, e, anything" and ate the "itec" in
        -- Architecture, producing "Archthat isture".
        replacements = {
          -- Task markers
          ['%f[%w]TODO%f[%W]:?'] = 'todo item',
          ['%f[%w]FIXME%f[%W]:?'] = 'fix me item',
          ['%f[%w]NOTE%f[%W]:?'] = 'note',
          ['%f[%w]WARNING%f[%W]:?'] = 'warning',
          ['%f[%w]TIP%f[%W]:?'] = 'tip',

          -- Technical acronyms
          ['%f[%w]API%f[%W]'] = 'A P I',
          ['%f[%w]URL%f[%W]'] = 'U R L',
          ['%f[%w]HTTP%f[%W]'] = 'H T T P',
          ['%f[%w]JSON%f[%W]'] = 'J son',
          ['%f[%w]SQL%f[%W]'] = 'S Q L',
          ['%f[%w]CSS%f[%W]'] = 'C S S',
          ['%f[%w]HTML%f[%W]'] = 'H T M L',
          ['%f[%w]JS%f[%W]'] = 'javascript',
          ['%f[%w]TS%f[%W]'] = 'TypeScript',
          ['%f[%w]AI%f[%W]'] = 'artificial intelligence',
          ['%f[%w]TL;DR%f[%W]'] = 'too long did not read',

          -- Custom identifiers
          -- ['%f[%w]MyApp%f[%W]'] = 'my app',
          -- ['%f[%w]BigCorp%f[%W]'] = 'big corp',
        },
        languages = {
          lua = {
            ['~='] = 'not equal',
            ['%.%.'] = 'concatenate',
          },
          python = {
            ['!='] = 'not equal',
            ['//'] = 'integer divide',
          },
          javascript = {
            ['=>'] = 'arrow function',
            ['==='] = 'strict equals',
            ['!=='] = 'strict not equals',
          },
          rust = {
            ['fn '] = 'function ',
            ['mut '] = 'mutable ',
            ['impl '] = 'implementation ',
          },
        },
      },

      -- Hooks
      hooks = {
        before_play = nil,              -- function(text) return modified_text end
        after_play = nil,               -- function(text) end; fires once when the whole run finishes
        on_state_change = nil,          -- function(new_state, old_state) end
        on_error = function(err)
          vim.notify('TTS Error: ' .. err, vim.log.levels.ERROR)
        end,
        on_queue_item = nil,            -- function(item, index, total) end; fires per segment
      },

      -- Notifications
      notifications = {
        level = vim.log.levels.INFO,
        use_notify = false,             -- Use vim.notify for notifications
      },
    })

    -- Treat a paragraph, not a line, as the unit that gets sentence-split.
    --
    -- Upstream breaks on every newline twice over: group_source_lines puts one
    -- source line in each group when segmentation is 'sentence', and
    -- split_segments then runs its own per-line gmatch. In hard-wrapped prose
    -- that cuts mid-sentence and the voice stops for breath in the wrong place.
    --
    -- The before_play hook could reshape the text in one line, but that path
    -- builds segments with no source range, and follow.show() bails without
    -- one, so the cursor highlight would quietly stop working. Hence overriding
    -- both functions here instead. Both fall through to the originals for the
    -- other segmentation modes.
    local utils = require('tts.utils')

    local function speakable(s)
      return s:match('[^%s%p]') ~= nil
    end

    local function sentence_mode()
      return (require('tts.config').get().playback.segmentation or 'sentence') == 'sentence'
    end

    local group_source_lines = utils.group_source_lines
    utils.group_source_lines = function(lines, start_line)
      if not sentence_mode() then
        return group_source_lines(lines, start_line)
      end

      local config = require('tts.config').get()
      local skip_code = config.preprocessing and config.preprocessing.skip_code_blocks
      local groups, group, first, last = {}, {}, nil, nil
      local in_fence = false

      local function flush()
        if #group > 0 then
          table.insert(groups, {
            text = table.concat(group, '\n'),
            first = first,
            last = last,
          })
        end
        group, first, last = {}, nil, nil
      end

      for i, line in ipairs(lines) do
        local buf_line = start_line + i - 1
        local skip = false

        if skip_code then
          if line:match('^%s*```') or line:match('^%s*~~~') then
            in_fence = not in_fence
            skip = true
          elseif in_fence then
            skip = true
          end
        end

        if skip or not speakable(line) then
          flush() -- a blank line or a code fence ends the paragraph
        else
          if not first then
            first = buf_line
          end
          last = buf_line
          table.insert(group, line)
        end
      end

      flush()
      return groups
    end

    local split_segments = utils.split_segments
    utils.split_segments = function(text)
      if not text or not sentence_mode() then
        return split_segments(text)
      end

      -- Join the lines within each paragraph, keep one newline between
      -- paragraphs. Upstream's per-line split then lands on paragraph bounds.
      local paragraphs, paragraph = {}, {}
      for line in (text .. '\n'):gmatch('([^\n]*)\n') do
        if line:match('^%s*$') then
          if #paragraph > 0 then
            table.insert(paragraphs, table.concat(paragraph, ' '))
            paragraph = {}
          end
        else
          table.insert(paragraph, vim.trim(line))
        end
      end
      if #paragraph > 0 then
        table.insert(paragraphs, table.concat(paragraph, ' '))
      end

      return split_segments(table.concat(paragraphs, '\n'))
    end
  end
}
