# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require "remap"
require "benchmark/ips"

class Fixed < Remap::Base
  define do
    map :a do
      map :b do
        map :c do
          map :d do
            map :e do
              map :f do
                map :g do
                  map :h do
                    map :i do
                      map :j do
                        map :k do
                          map :l do
                            map :m do
                              map :n do
                                map :o do
                                  map :p do
                                    map :q do
                                      map :r do
                                        map :s do
                                          map :t do
                                            map :u do
                                              map :v do
                                                map :w do
                                                  map :x do
                                                    map :y do
                                                      map :z do
                                                        to :a
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    map :z do
      map :a do
        map :b do
          map :c do
            map :d do
              map :e do
                map :f do
                  map :g do
                    map :h do
                      map :i do
                        map :j do
                          map :k do
                            map :l do
                              map :m do
                                map :n do
                                  map :o do
                                    map :p do
                                      map :q do
                                        map :r do
                                          map :s do
                                            map :t do
                                              map :u do
                                                map :v do
                                                  map :w do
                                                    map :x do
                                                      map :y do
                                                        map :z do
                                                          to :a
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

input = {
  z: {
    a: {
      b: {
        c: {
          d: {
            e: {
              f: {
                g: {
                  h: {
                    i: {
                      j: {
                        k: {
                          l: {
                            m: {
                              n: {
                                o: {
                                  p: {
                                    q: {
                                      r: {
                                        s: {
                                          t: {
                                            u: {
                                              v: {
                                                w: {
                                                  x: {
                                                    y: {
                                                      z: "U"
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  a: {
    b: {
      c: {
        d: {
          e: {
            f: {
              g: {
                h: {
                  i: {
                    j: {
                      k: {
                        l: {
                          m: {
                            n: {
                              o: {
                                p: {
                                  q: {
                                    r: {
                                      s: {
                                        t: {
                                          u: {
                                            v: {
                                              w: {
                                                x: {
                                                  y: {
                                                    z: "U"
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

# GC.disable
Benchmark.ips do |x|
  x.report("fixed") { Fixed.call(input) }

  x.compare!
end
