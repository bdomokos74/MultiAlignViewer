class MultiAlignAnnotator

  def write_gtf(fname, gtf_arr, trans_id)
    f = File.open(fname, "w")
    gtf_arr.each do |rec|
      row = [rec.seqname, rec.source, rec.feature,
             rec.start.to_i, rec.end.to_i,
             rec.score, rec.strand, rec.frame, "transcript_id \"#{trans_id}\""].join("\t").concat("\n")
      f.write(row)
    end
    f.close()
  end

  def create_gtf_record(exon, rel_start, rel_end)
    result = Bio::GFF::Record.new( [exon.seqname, exon.source, exon.feature,
                                    exon.start.to_i+rel_start, exon.start.to_i+rel_end,
                                    exon.score, exon.strand, exon.frame].join("\t") )
    return(result)
  end

#   exon   " ---  -- "
#                 ^
#  seq =   "AGTCC"
#              ^
#  match = " *** "
#              ^
  def create_conserved(seq, match_line, exons)
    #print "Debug\n\nseq: #{seq}\nmatch line: #{match_line}\ntranscript: #{exons}\n"
    result = []

    curr_exon_num = 0
    curr_exon_pos = 0
    curr_exon = exons[curr_exon_num]
    curr_transcript_pos = 0
    in_conserved = false
    curr_conserved_start = 0

    while curr_transcript_pos<seq.length
      #p [curr_exon_num, curr_exon_pos, curr_transcript_pos, in_conserved]
      if seq[curr_transcript_pos]=='-'
        ins_rec = create_gtf_record(curr_exon, curr_exon_pos, curr_exon_pos)
        ins_rec.feature = "deletion"
        result << ins_rec
      end
      while seq[curr_transcript_pos]=='-' and curr_transcript_pos<seq.length
        curr_transcript_pos += 1
      end
      break if curr_transcript_pos==seq.length
      if curr_exon_pos > (curr_exon.start.to_i-curr_exon.end.to_i).abs
        if in_conserved
          result << create_gtf_record(curr_exon, curr_conserved_start, curr_exon_pos-1)
        end
        curr_exon_pos = 0
        curr_exon_num +=1
        curr_exon = exons[curr_exon_num]

        in_conserved = false
        next
      end

      if in_conserved
        if match_line[curr_transcript_pos] == ' '
          result << create_gtf_record(curr_exon, curr_conserved_start, curr_exon_pos-1)
          in_conserved = false
        end
      else
        if match_line[curr_transcript_pos] == '*'
          in_conserved = true
          curr_conserved_start = curr_exon_pos
        end
      end
      curr_transcript_pos += 1
      curr_exon_pos += 1
    end

    if in_conserved
      #p [curr_exon_num, curr_exon_pos, curr_transcript_pos, in_conserved]
      result << create_gtf_record(curr_exon, curr_conserved_start, curr_exon_pos-1)
    end
    return(result)
  end

  def create_gapped_features(seq, features)

    curr_aligned_pos = 0
    curr_feature = 0
    start_pos = 0
    result = []

    while curr_feature <features.length
      n = features[curr_feature].end.to_i - features[curr_feature].start.to_i + 1
      for i in (1..n)
        while seq[curr_aligned_pos] == "-"
          curr_aligned_pos += 1
        end
        curr_aligned_pos += 1
      end
      gapped_feature = {:name => "exon_#{curr_feature+1}",
                                      :start => start_pos,
                                      :end => curr_aligned_pos-1}
      result << gapped_feature
      curr_feature += 1
      start_pos = curr_aligned_pos
    end
    return result
  end

  def create_features( features)
    p "FEATURELEN: "+features.length
    if(features.length==1)
      n = features[0].end.to_i - features[0].start.to_i
      return [{:name => "exon_1",
               :start => 0,
               :end => n}]
    end
    start_pos = 0
    result = []
    for i in (0..(features.length-1))
      n = features[i].end.to_i - features[i].start.to_i
      gapped_feature = {:name => "exon_#{i+1}",
                        :start => start_pos,
                        :end => start_pos+n}
      result << gapped_feature
      start_pos = start_pos+n+1
    end
    return result
  end

end
