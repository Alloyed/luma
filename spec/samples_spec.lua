require 'spec.run'

local sample = it

describe("Code sample:", function()
	sample("fizzbuzz", function()
		run [[
(define (fizzbuzz n)
  (cond
    ((= (mod n 15) 0) "Fizzbuzz")
    ((= (mod n 5) 0) "Fizz")
    ((= (mod n 3) 0) "Buzz")
    (:else (tostring n))))

(doall (map string.concat (intersperse "\n" (map fizzbuzz (range 100)))))
		]]
	end)
end)
