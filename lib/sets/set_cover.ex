defmodule Algorithms.Sets.SetCover do
  @moduledoc """
  Solves the Set Cover problem using dynamic programming with bitmasks.

  Given a list of required skills and a list of people with their skills,
  finds the minimum set of people that covers all required skills.

  ## Mnemonic
  Map: skills → bit indices, people → bitmasks
  Build: DP table {skill_mask → {min_team_size, team_indices}}
  Iterate: each person, try adding to all existing states
    OR: person_mask with current_mask → new_mask
    Update: if new_mask is smaller team OR lexicographically larger when tied
  Return: sorted team indices for target mask (all skills covered)

  ## Parameters
  - req_skills: List of required skills (strings)
  - people: List of lists, where each inner list contains the skills of a person

  ## Returns
  List of indices representing the selected people

  ## Examples
      iex> SetCover.run(["java", "nodejs"], [["java"], ["nodejs"]])
      [0, 1]

      iex> SetCover.run(["java", "nodejs"], [["java", "nodejs"]])
      [0]

  Triadic Pseudocode Protocol:
    ALGO SetCover(universe, sets)  # Greedy approx
    ├── DATA: IN: universe U, sets S → OUT: min cover sets[]
    │   ├── covered: bitset/set for U
    ├── ENUMERATE: WHILE covered != U
    │   └── SELECT set with max |set - covered|
    └── CONDITIONAL:
        └── ADD selected to cover
        └── covered ∪= selected set
        # DP exact: 2^|S| states, too exponential for triad
  """
  def run(req_skills, people) do
    # Use dynamic programming with bitmasks to find the optimal solution
    dp_set_cover(req_skills, people)
  end

  # DP solution using bitmasks
  defp dp_set_cover(req_skills, people) do
    skill_to_idx = req_skills |> Enum.with_index() |> Map.new()
    people_masks = convert_people_to_masks(people, skill_to_idx)
    target = Bitwise.bsl(1, length(req_skills)) - 1

    dp = build_dp_table(people_masks, target)

    case Map.get(dp, target) do
      nil -> raise "Cannot cover all required skills with available people"
      {_size, team} -> Enum.sort(team)
    end
  end

  # Convert each person's skills to a bitmask
  defp convert_people_to_masks(people, skill_to_idx) do
    Enum.map(people, &skills_to_bitmask(&1, skill_to_idx))
  end

  # Convert a list of skills to a bitmask
  defp skills_to_bitmask(skills, skill_to_idx) do
    Enum.reduce(skills, 0, fn skill, mask ->
      case Map.get(skill_to_idx, skill) do
        nil -> mask
        idx -> Bitwise.bor(mask, Bitwise.bsl(1, idx))
      end
    end)
  end

  # Build DP table by trying to add each person
  defp build_dp_table(people_masks, _target) do
    people_masks
    |> Enum.with_index()
    |> Enum.reduce(%{0 => {0, []}}, fn {person_mask, person_idx}, acc ->
      if person_mask == 0 do
        acc
      else
        add_person_to_states(acc, person_idx, person_mask)
      end
    end)
  end

  # Try adding a person to all existing states
  defp add_person_to_states(dp, person_idx, person_mask) do
    dp
    |> Enum.reduce(dp, fn {current_mask, {team_size, team}}, acc ->
      new_mask = Bitwise.bor(current_mask, person_mask)

      if new_mask == current_mask do
        acc
      else
        update_dp_state(acc, new_mask, person_idx, team_size, team)
      end
    end)
  end

  # Update DP state for a new mask
  defp update_dp_state(dp, new_mask, person_idx, team_size, team) do
    new_team = [person_idx | team]
    new_size = team_size + 1

    case Map.get(dp, new_mask) do
      nil ->
        Map.put(dp, new_mask, {new_size, new_team})

      {existing_size, _existing_team} when new_size < existing_size ->
        Map.put(dp, new_mask, {new_size, new_team})

      {existing_size, existing_team} when new_size == existing_size ->
        if Enum.sort(new_team) > Enum.sort(existing_team) do
          Map.put(dp, new_mask, {new_size, new_team})
        else
          dp
        end

      _ ->
        dp
    end
  end
end
