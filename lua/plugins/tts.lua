{
  'chriswritescode-dev/tts.nvim',
  config = function()
    require('tts').setup({
      -- Backend selection: 'auto', 'macos', 'openai'
      backend = 'auto',

      -- macOS configuration
      macos = {
        voice = 'Alex',
        rate = 200,              -- 75-720 words per minute
        volume = 0.5,            -- 0.0-1.0
        audio_device = nil,      -- Custom audio device
        pitch = nil,             -- Voice pitch
        modulation = nil,        -- Voice modulation
      },

      -- OpenAI configuration
      openai = {
        api_key = vim.env.OPENAI_API_KEY,
        api_url = 'https://api.openai.com/v1/audio/speech',
        model = 'tts-1',         -- or 'tts-1-hd'
        voice = 'alloy',         -- alloy, echo, fable, onyx, nova, shimmer
        speed = 1.0,             -- 0.25-4.0
        format = 'mp3',          -- mp3, opus, aac, flac
        headers = {},            -- Custom headers
        timeout = 30,            -- Request timeout in seconds
      },

      -- Playback behavior
      playback = {
        auto_clear_queue = false,
        show_progress = true,
        segmentation = 'line',               -- Split text into segments: 'line', 'sentence', or 'none'
        lines_per_segment = 5,               -- 'line' mode only: how many lines make up one segment
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
        replacements = {
          -- Task markers
          ['TODO:?'] = 'todo item',
          ['FIXME:?'] = 'fix me item',
          ['NOTE:?'] = 'note',
          ['WARNING:?'] = 'warning',
          ['TIP:?'] = 'tip',

          -- Technical acronyms
          ['API'] = 'A P I',
          ['URL'] = 'U R L',
          ['HTTP'] = 'H T T P',
          ['JSON'] = 'J son',
          ['SQL'] = 'S Q L',
          ['CSS'] = 'C S S',
          ['HTML'] = 'H T M L',
          ['JS'] = 'javascript',
          ['TS'] = 'TypeScript',
          ['AI'] = 'artificial intelligence',
          ['TL;DR'] = 'too long did not read',

          -- Common abbreviations
          ['etc.'] = 'etcetera',
          ['i.e.'] = 'that is',
          ['e.g.'] = 'for example',

          -- Custom identifiers
          -- ['MyApp'] = 'my app',
          -- ['BigCorp'] = 'big corp',
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
  end
}
