`timescale 1ns/1ps

module rsa_core_tb;

  // Parameters (using pure Verilog parameters)
  parameter CLK_PERIOD   = 20;
  parameter DATA_FILE    = "stimulus.txt";
  parameter CHECKER_FILE = "checker.txt";
  parameter RESULT_FILE  = "result.txt";
  parameter RESET        = 1'b0;
  parameter LOAD         = 1'b0;

  // Signal declarations
  reg         core_clk;
  reg         core_rst;
  reg         core_load;
  reg  [7:0]  core_din;
  wire        core_done;
  wire        core_err;
  wire [7:0]  core_dout;

  // DUV instantiation (Assuming module rsa_core is defined elsewhere)
  rsa_core duv (
      .core_clk  (core_clk),
      .core_rst  (core_rst),
      .core_load (core_load),
      .core_din  (core_din),
      .core_done (core_done),
      .core_err  (core_err),
      .core_dout (core_dout)
  );

  // CLOCK GENERATION
  initial begin
    core_clk = 1'b0;
    forever
      #(CLK_PERIOD/2) core_clk = ~core_clk;
  end

  // RESET GENERATION
  initial begin
    // Initially drive reset to the inverse of the RESET parameter.
    core_rst = ~RESET;
    #(5*CLK_PERIOD);
    core_rst = RESET;
    #(2*CLK_PERIOD);
    core_rst = ~RESET;
  end

  // STIMULUS GENERATION
  initial begin : stimulus_block
    integer stim_file;
    integer stim_val;
    core_load = ~LOAD; // Initialize load signal

    // Open the stimulus file in read mode
    stim_file = $fopen(DATA_FILE, "r");
    if (stim_file == 0) begin
      $display("ERROR: Could not open file %s", DATA_FILE);
      $finish;
    end

    // Loop reading three stimulus values per iteration (similar to the VHDL code)
    forever begin
      #(20000*CLK_PERIOD);
      if ($fscanf(stim_file, "%h\n", stim_val) != 1)
         disable stimulus_block;
      core_load = LOAD;
      core_din  = stim_val[7:0];
      #CLK_PERIOD;
      core_load = ~LOAD;
      #(10*CLK_PERIOD);

      if ($feof(stim_file))
         disable stimulus_block;
      if ($fscanf(stim_file, "%h\n", stim_val) != 1)
         disable stimulus_block;
      core_load = LOAD;
      core_din  = stim_val[7:0];
      #CLK_PERIOD;
      core_load = ~LOAD;
      #(10*CLK_PERIOD);

      if ($feof(stim_file))
         disable stimulus_block;
      if ($fscanf(stim_file, "%h\n", stim_val) != 1)
         disable stimulus_block;
      core_load = LOAD;
      core_din  = stim_val[7:0];
      #CLK_PERIOD;
      core_load = ~LOAD;
      #(10*CLK_PERIOD);
    end
    $fclose(stim_file);
  end

  // CHECKER PROCESS
  initial begin : checker_block
    integer checker_file;
    integer result_file;
    integer test_num;
    integer fscanf_status;
    integer expected_val;
    reg [7:0] expected;
    test_num = 0;

    // Open checker file for reading and result file for writing.
    checker_file = $fopen(CHECKER_FILE, "r");
    if (checker_file == 0) begin
      $display("ERROR: Could not open file %s", CHECKER_FILE);
      $finish;
    end

    result_file = $fopen(RESULT_FILE, "w");
    if (result_file == 0) begin
      $display("ERROR: Could not open file %s", RESULT_FILE);
      $finish;
    end

    // Write header lines to the result file.
    $fdisplay(result_file, "-------------------------------------------------------------------------------");
    $fdisplay(result_file, "InPlace Design Automation");
    $fdisplay(result_file, "Simulation Results");
    $fdisplay(result_file, "-------------------------------------------------------------------------------");
    $fdisplay(result_file, "             Result       Expected");

    // Loop until the checker file reaches end-of-file.
    while (!$feof(checker_file)) begin
      wait (core_done == 1);
      test_num = test_num + 1;
      fscanf_status = $fscanf(checker_file, "%h\n", expected_val);
      if (fscanf_status != 1)
         disable checker_block; // Exit the block if fscanf fails
      expected = expected_val[7:0];

      // Compare the DUV output against the expected value.
      if (core_dout === expected)
        $fdisplay(result_file, "Test %6d: %h === %h [PASSED]", test_num, core_dout, expected);
      else
        $fdisplay(result_file, "Test %6d: %h =/= %h [FAILED]", test_num, core_dout, expected);

      wait (core_done == 0);
    end

    // Write footer and close files.
    $fdisplay(result_file, "-------------------------------------------------------------------------------");
    $fdisplay(result_file, "End of Simulation");
    $fclose(checker_file);
    $fclose(result_file);
    $stop;
  end

endmodule
