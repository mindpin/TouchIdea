class String
  def block len=80,str = '...'
    if self.length > (len - 3)
      return self[0, len - 3] + str
    end
    self
  end
end

