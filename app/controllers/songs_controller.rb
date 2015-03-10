class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.paginate(page: params[:page], per_page: 10)
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    require 'grooveshark'
    client = Grooveshark::Client.new
    session = client.session
    songs = client.search_songs("#{@song.artist.name} #{@song.name} #{@song.album.title}")
    @track = songs.first

    require 'musix_match'
    MusixMatch::API::Base.api_key = ENV['musixmatch']
    response = MusixMatch.search_track(q: "#{@song.artist.name} #{@song.name}")
    if response.status_code == 200
      response.each do |track|
        @lyric_id = track.track_id
      end
      lyric_response = MusixMatch.get_lyrics(@lyric_id)
      if lyric_response.status_code == 200 && lyrics = lyric_response.lyrics
        @lyrics = lyrics.lyrics_body
      end
    end

  end

  # GET /songs/new
  def new
    @song = Song.new
    @artists = Artist.all
    @albums = Album.all
    @genres = Genre.all
  end

  # GET /songs/1/edit
  def edit
    @artists = Artist.all
    @albums = Album.all
    @genres = Genre.all
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(song_params)

    respond_to do |format|
      if @song.save
        format.html { redirect_to @song, notice: 'Song was successfully created.' }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: 'Song was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def song_params
      params.require(:song).permit(:name, :genre_id, :artist_id, :album_id)
    end
end
