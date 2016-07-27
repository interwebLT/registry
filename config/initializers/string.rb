class String
  def numeric?
    self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
  end
end
