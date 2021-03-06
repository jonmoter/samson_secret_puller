module SamsonSecretPuller
  FOLDER = '/secrets'.freeze
  TIMEOUT = 60

  class TimeoutError < StandardError
  end

  class << self
    def [](key)
      secrets[key]
    end

    def fetch(*args, &block)
      secrets.fetch(*args, &block)
    end

    def keys
      secrets.keys
    end

    private

    def secrets
      @secrets ||= begin
        secrets = ENV.to_h

        if File.exist?(FOLDER)
          wait_for_secrets_to_appear
          merge_secrets(secrets)
        end

        secrets
      end
    end

    def merge_secrets(secrets)
      Dir.glob("#{FOLDER}/*").each do |file|
        name = File.basename(file)
        next if name.start_with?(".") # ignore .done and maybe others
        secrets[name] = File.read(file).strip
      end
    end

    def wait_for_secrets_to_appear
      start = Time.now
      done_file = "#{FOLDER}/.done"
      # secrets should appear in that folder any second now
      until File.exist?(done_file)
        if Time.now > start + TIMEOUT
          raise TimeoutError, "Waited #{TIMEOUT} seconds for #{done_file} to appear."
        else
          warn 'waiting for secrets to appear'
          sleep 0.1
        end
      end
    end
  end
end
