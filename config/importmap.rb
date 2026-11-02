# Pin npm packages by running ./bin/importmap

pin "application"
# Turbo (Drive, Frames, Streams) + клиент Action Cable — всё внутри turbo.min.js из гема turbo-rails
pin "@hotwired/turbo-rails", to: "turbo.min.js"
