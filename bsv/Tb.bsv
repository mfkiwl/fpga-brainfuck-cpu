// -------------------------------------------------------------------------------
//  PROJECT: FPGA Brainfuck
// -------------------------------------------------------------------------------
//  AUTHORS: Pavel Benacek <pavel.benacek@gmail.com>
//  LICENSE: The MIT License (MIT), please read LICENSE file
//  WEBSITE: https://github.com/benycze/fpga-brainfuck/
// -------------------------------------------------------------------------------

package Tb;

import bcpu :: *;

    module mkTb (Empty);
        
        rule hello_rule;
            $display("Hello world!");
            $finish;
        endrule

    endmodule : mkTb 
endpackage : Tb