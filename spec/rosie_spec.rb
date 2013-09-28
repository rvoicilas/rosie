require 'spec_helper'

module Rosie
  describe Rosie do
    describe 'when help should be displayed' do
      before(:each) do
        @expected = <<EOS
Usage: rosie [options] [subcommand [options] [subcommand [options]]]
    -u, --url [URL]                  Jenkins CI url
    -h, --help                       Display app help
EOS
      end

      describe 'when no command is given' do
        it 'should print help and exit' do
          _, err = capture_io do
            run_with_rescue { Rosie.run([]) }
          end
          assert_equal @expected, err
        end
      end

      describe 'when help was requested' do
        it 'should print help and exit' do
          # When only --help has been passed in
          _, err = capture_io do
            run_with_rescue { Rosie.run(['--help']) }
          end
          assert_equal @expected, err

          # When some other option, other than --help hass been passed in
          _, err = capture_io do
            run_with_rescue { Rosie.run(['--url', 'http://jk.is', '--help']) }
          end
          assert_equal @expected, err
        end
      end
    end

    describe 'when unknown command' do
      before(:each) do
        @expected = <<EOS
show [options] subcommand [options]
    -v, --verbose                    Run verbosely
EOS
      end

      it 'should fail and write to stderr when no subsequent options given' do
        _, err = capture_io do
          run_with_rescue { Rosie.run(['invalid']) }
        end
        assert_equal @expected, err
      end

      it 'should fail and write to stderr even when options are given' do
        _, err = capture_io do
          run_with_rescue { Rosie.run(['invalid', '--verbose']) }
        end
        assert_equal @expected, err
      end
    end

    describe 'when known command' do
      it 'should fail if no subcommand has been given' do
        _, err = capture_io do
          # show should be treated as a command and --verbose should
          # be added to options, leaving argv empty
          run_with_rescue { Rosie.run(['show', '--verbose']) }
        end
        expected = <<EOS
show [options] subcommand [options]
    -v, --verbose                    Run verbosely
EOS
        assert_equal expected, err
      end
    end

    describe 'when unknown subcommand' do
      it 'should fail and write to stderr' do
        _, err = capture_io do
          run_with_rescue { Rosie.run(['show', '--verbose', 'invalid']) }
        end
        expected = <<EOS
failures [options]
        --view [VIEW]
                                     Specify which view to use
EOS
        assert_equal expected, err
      end
    end

    describe 'when invalid options are found' do
      it 'should display a summary of all the available info and exit' do
        _, err = capture_io do
          run_with_rescue { Rosie.run(['show', '--verbose', 'failures',
                                       'these', 'are', 'invalid']) }
        end
        expected = <<EOS
Usage: rosie [options] [subcommand [options] [subcommand [options]]]
    -u, --url [URL]                  Jenkins CI url
    -h, --help                       Display app help

show [options] subcommand [options]
    -v, --verbose                    Run verbosely

failures [options]
        --view [VIEW]
                                     Specify which view to use
EOS
        assert_equal expected, err
      end
    end
  end
end
