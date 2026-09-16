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
  end
}
