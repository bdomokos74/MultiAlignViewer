require "test/unit"
require "bio"
#require './multialign_annotator'

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_create_gtf_record
    result = MultiAlignAnnotator.new().create_gtf_record(Bio::GFF::Record.new("SEQ\tSOURCE\texon\t2\t4\t0.5\t+"), 2,3)
    assert_equal([4,5 ], [result.start.to_i, result.end.to_i])
  end

  def test_create_conserved_1
    # exon  "-----"
    seq =   "AGTCC"
    match = " *** "
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t1\t5")
    ]
    #p "test_create_conserved_2"
    result = MultiAlignAnnotator.new().create_conserved(seq, match, exons)
    #p result
    assert_equal(1, result.length)
    assert_equal([2, 4], [result[0].start.to_i, result[0].end.to_i])
  end

  def test_create_conserved_2
    # exon  " ---  -- "
    seq =   "AGTCC"
    match = " *** "
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t2\t4"),
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t7\t8")
    ]
    #p "test_create_conserved_1"
    result = MultiAlignAnnotator.new().create_conserved(seq, match, exons)
    #p result
    assert_equal(2, result.length)
    assert_equal([3, 4, 7, 7], [result[0].start.to_i, result[0].end.to_i, result[1].start.to_i, result[1].end.to_i])
  end

  def test_create_conserved_3
    # exon  " ---  -- -----"
    seq =   "AGTCCTATAT"
    match = " ***  **  "
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t2\t4"),
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t7\t8"),
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t10\t14")
    ]
    #p "test_create_conserved_1"
    result = MultiAlignAnnotator.new().create_conserved(seq, match, exons)
    #p result
    assert_equal(3, result.length)
    assert_equal([3, 4, 7, 7, 11, 12],
                 [result[0].start.to_i, result[0].end.to_i,
                  result[1].start.to_i, result[1].end.to_i,
                  result[2].start.to_i, result[2].end.to_i])
  end

  def test_create_conserved_4
    #        12345678901234
    # exon  " ---  -- -----"
    seq =   "AGTCC-TATAT"
    match = " ***   **  "
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t2\t4"),
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t7\t8"),
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t10\t14")
    ]
    #p "test_create_conserved_1"
    result = MultiAlignAnnotator.new().create_conserved(seq, match, exons)
    #p result
    assert_equal(4, result.length)
    assert_equal([3, 4, 7, 7, 9,9, 11, 12],
                 [result[0].start.to_i, result[0].end.to_i,
                  result[1].start.to_i, result[1].end.to_i,
                  result[2].start.to_i, result[2].end.to_i,
                  result[3].start.to_i, result[3].end.to_i])
  end

  def test_create_gapped_features_1
    #        12345   67890
    #        1234567890123
    #        01234567890123
    seq =   "AGTCC---TATAT"
    #        ^        ^
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t1\t7")
    ]
    result = MultiAlignAnnotator.new().create_gapped_features(seq, exons)
    assert_equal(1, result.length)
    assert_equal(["exon_1", 0, 9],
                 [result[0][:name], result[0][:start], result[0][:end]
                 ])
  end
  def test_create_gapped_features_2
    #        12345   67890
    #        1234567890123
    #        01234567890123
    seq =   "AGTCC---TATAT"
    #        ^^
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t1\t1")
    ]
    result = MultiAlignAnnotator.new().create_gapped_features(seq, exons)
    assert_equal(1, result.length)
    assert_equal(["exon_1", 0, 0],
                 [result[0][:name], result[0][:start], result[0][:end],
                 ])
  end
  def test_create_gapped_features_3
    #        12345   67890
    #        1234567890123
    #        01234567890123
    seq =   "AGTCC---TATAT"
    #        ^   ^    ^
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t1\t1"),
        Bio::GFF::Record.new("SEQ2\tSOURCE\texon\t5\t7")
    ]
    result = MultiAlignAnnotator.new().create_gapped_features(seq, exons)
    assert_equal(2, result.length)
    assert_equal(["exon_1", 0, 0, "exon_2", 1, 3 ],
                 [result[0][:name], result[0][:start], result[0][:end],
                 result[1][:name], result[1][:start], result[1][:end]
                 ])
  end

  def test_create_features_1
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t1\t2"),
        Bio::GFF::Record.new("SEQ2\tSOURCE\texon\t5\t7")
    ]
    result = MultiAlignAnnotator.new().create_features(exons)
    assert_equal(2, result.length)
    assert_equal(["exon_1", 0, 1, "exon_2", 2, 4 ],
                 [result[0][:name], result[0][:start], result[0][:end],
                  result[1][:name], result[1][:start], result[1][:end]
                 ])
  end
  def test_create_features_2
    exons = [
        Bio::GFF::Record.new("SEQ\tSOURCE\texon\t2\t3"),
        Bio::GFF::Record.new("SEQ2\tSOURCE\texon\t5\t7")
    ]
    result = MultiAlignAnnotator.new().create_features(exons)
    assert_equal(2, result.length)
    assert_equal(["exon_1", 0, 1, "exon_2", 2, 4 ],
                 [result[0][:name], result[0][:start], result[0][:end],
                  result[1][:name], result[1][:start], result[1][:end]
                 ])
  end
end

