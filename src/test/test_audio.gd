extends GutTest

func test_synchsafe_to_int():
	var audio = Audio.new(AudioStreamPlayer.new())
	assert_eq(127, audio.bytes_to_int([127]))
	assert_eq(255, audio.bytes_to_int([1,127]))
	assert_eq(0, audio.bytes_to_int([0,0,0,0]))
	assert_eq(65535, audio.bytes_to_int([3,127,127]))
