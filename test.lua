vim.system({ "kitten", "@ls" },
  {
    text = true,
    stdout = function(_, data)
      vim.system({ "jq", '[.[] | .tabs | .[] | { id: .id, title: .title }]' }, {
        text = true,
        stdin = data,
        stdout = function(err, json)
          if (err) then
            vim.notify(err, vim.diagnostic.severity.ERROR)
            return
          end
          if (not json) then
            return
          end
          local projs = vim.json.decode(json, { object = true, array = true })
          local titles = {}
          for _, proj in ipairs(projs) do
            table.insert(titles, proj.title)
          end

          vim.schedule(function()
            vim.ui.select(titles, { prompt = "Select project" }, function(_, idx)
              if (idx) then
                vim.system({ "kitten", "@focus-tab", "--match", "id:" .. projs[idx].id })
              end
            end)
          end
          )
        end
      })
    end
  })
