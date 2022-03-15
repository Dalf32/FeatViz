# frozen_string_literal: true

# ScrapedFeat
#
# AUTHOR::  Kyle Mullins

class ScrapedFeat
  attr_reader :name, :prerequisites, :description, :url

  def initialize(name, prerequisites, description, url)
    @flags = []
    @name = strip_flags(name)
    @description = description
    @url = url

    @prerequisites = prerequisites
    @prerequisites = prerequisites.split(', ') if prerequisites.is_a?(String)
    @prerequisites.delete('—')
  end

  def root?
    @prerequisites.empty?
  end

  def combat?
    @flags.include?(:combat)
  end

  def armor_mastery?
    @flags.include?(:armor_mastery)
  end

  def shield_mastery?
    @flags.include?(:shield_mastery)
  end

  def weapon_mastery?
    @flags.include?(:weapon_mastery)
  end

  def prereq_feats(all_feats)
    prerequisites.map { |p| all_feats.find { |f| f.name == p } }.compact
  end

  def to_s
    "#{@name} - #{@description}"
  end

  private

  def strip_flags(name_str)
    if name_str.include?('*')
      @flags << :combat
      name_str = name_str.gsub('*', '')
    end

    if name_str.include?('⊤⊤⊤')
      @flags << :weapon_mastery
      name_str = name_str.gsub('⊤⊤⊤', '')
    end

    if name_str.include?('⊤⊤')
      @flags << :shield_mastery
      name_str = name_str.gsub('⊤⊤', '')
    end

    if name_str.include?('⊤')
      @flags << :armor_mastery
      name_str = name_str.gsub('⊤', '')
    end

    name_str
  end
end
