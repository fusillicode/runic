class ApiConstraints
  attr_reader :version, :default
  alias_method :default?, :default

  def initialize(version:, default: false)
    @version, @default = version, default
  end

  def matches?(request)
    default? || request.headers['Accept'].include?(api_version_header)
  end

  def api_version_header
    "application/#{Rails.application.class.parent_name}.v#{version}"
  end
end
