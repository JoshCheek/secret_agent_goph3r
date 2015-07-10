class Exfiltrate
  ExfiltrateError = Class.new StandardError
  YouFuckedUp     = Class.new ExfiltrateError
  UnhandledEvent  = Class.new ExfiltrateError

  def self.call(gophers)
    gopher = gophers.first
  end
end
