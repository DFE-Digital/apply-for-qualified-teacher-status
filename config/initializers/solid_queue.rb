# frozen_string_literal: true

SolidQueue.on_start { Rails.logger.level = Logger::WARN }
